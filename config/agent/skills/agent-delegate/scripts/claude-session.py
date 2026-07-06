#!/usr/bin/env python3
"""Keep one read-only Claude Code process alive for a multi-turn lane."""

import argparse
import json
import os
from pathlib import Path
import queue
import signal
import sys
import termios
import threading

# Keep this before the sibling import so shared skills never receive bytecode.
sys.dont_write_bytecode = True

from claude_session_support import (  # noqa: E402
    die,
    emit,
    load_state,
    lock_directory,
    pump,
    require_transcript,
    save,
    start_process,
    stop_process,
)


def arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="command", required=True)
    start = commands.add_parser("start")
    start.add_argument("directory", type=Path)
    start.add_argument("--model", required=True)
    start.add_argument("--effort", choices=("low", "medium", "high", "xhigh", "max"))
    recover = commands.add_parser("recover")
    recover.add_argument("directory", type=Path)
    return parser.parse_args()


def run_turn(request: dict, process, messages: queue.Queue, directory: Path,
             state_path: Path, state: dict) -> None:
    prompt = request.get("prompt")
    if not isinstance(prompt, str) or not prompt.strip():
        emit({"type": "manager_error", "error": "prompt must be non-empty"})
        return
    state["turn_complete"] = False
    save(state_path, state)
    payload = {
        "type": "user", "message": {"role": "user", "content": prompt},
        "parent_tool_use_id": None, "session_id": state["session_id"],
    }
    try:
        process.stdin.write(json.dumps(payload) + "\n")
        process.stdin.flush()
    except (BrokenPipeError, OSError) as error:
        die(f"Claude input failed ({error}); inspect stderr.log")
    result = None
    while result is None:
        event = messages.get()
        if event is None:
            die("Claude exited before a result; inspect stderr.log")
        if event.get("type") == "result":
            result = event
    if result.get("session_id") != state["session_id"]:
        die("result session_id does not match session.json")
    if result.get("is_error") or result.get("subtype") != "success":
        die(f'Claude result failed with subtype {result.get("subtype")!r}')
    reply = result.get("result")
    if not isinstance(reply, str) or not reply.strip():
        die("result contains no final reply")
    require_transcript(state)
    (directory / "reply.txt").write_text(reply + "\n", encoding="utf-8")
    state["turn_complete"] = True
    save(state_path, state)


def main() -> None:
    args = arguments()
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    if os.environ.get("CLAUDE_CODE_SKIP_PROMPT_HISTORY"):
        die("CLAUDE_CODE_SKIP_PROMPT_HISTORY disables recovery")
    directory = args.directory.expanduser().resolve()
    state_path = directory / "session.json"
    state = load_state(args, directory, state_path)
    lock = lock_directory(directory)
    interrupted = False
    with (directory / "events.jsonl").open("a", encoding="utf-8") as events, (
        directory / "stderr.log").open("a", encoding="utf-8") as errors:
        process = start_process(args.command, state, errors)
        messages: queue.Queue = queue.Queue()
        reader = threading.Thread(
            target=pump, args=(process.stdout, events, messages), daemon=True,
        )
        reader.start()
        state["manager_pid"] = os.getpid()
        save(state_path, state)
        terminal = termios.tcgetattr(sys.stdin) if sys.stdin.isatty() else None
        if terminal:
            streaming_terminal = terminal.copy()
            streaming_terminal[3] &= ~(termios.ECHO | termios.ICANON)
            termios.tcsetattr(sys.stdin, termios.TCSANOW, streaming_terminal)
        emit({"type": "manager_ready", "session_id": state["session_id"],
              "recovered": args.command == "recover"})
        try:
            for line in sys.stdin:
                try:
                    request = json.loads(line)
                except json.JSONDecodeError:
                    emit({"type": "manager_error", "error": "invalid JSON request"})
                    continue
                if request.get("type") == "close":
                    break
                run_turn(request, process, messages, directory, state_path, state)
        except KeyboardInterrupt:
            interrupted = True
        finally:
            stop_process(process, interrupted)
            reader.join(timeout=5)
            state.pop("manager_pid", None)
            save(state_path, state)
            if terminal:
                termios.tcsetattr(sys.stdin, termios.TCSANOW, terminal)
            emit({"type": "manager_stopped", "interrupted": interrupted})
    lock.close()


def interrupt(_signum, _frame) -> None:
    raise KeyboardInterrupt


for watched_signal in (signal.SIGHUP, signal.SIGINT, signal.SIGTERM):
    signal.signal(watched_signal, interrupt)

if __name__ == "__main__":
    main()
