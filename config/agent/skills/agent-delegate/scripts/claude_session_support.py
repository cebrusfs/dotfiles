"""Lifecycle and persisted-state support for the Claude session manager."""

import fcntl
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import uuid

TOOLS = "Read,Grep,Glob"


def die(message: str, code: int = 1) -> None:
    print(f"claude-session: {message}", file=sys.stderr)
    raise SystemExit(code)


def save(path: Path, state: dict) -> None:
    temporary = path.with_suffix(".tmp")
    temporary.write_text(
        json.dumps(state, indent=2, sort_keys=True) + "\n", encoding="utf-8",
    )
    temporary.replace(path)


def emit(event: dict) -> None:
    print(json.dumps(event, separators=(",", ":")), flush=True)


def pump(stream, events, messages) -> None:
    try:
        for line in stream:
            events.write(line)
            events.flush()
            print(line, end="", flush=True)
            try:
                messages.put(json.loads(line))
            except json.JSONDecodeError:
                pass
    finally:
        messages.put(None)


def require_transcript(state: dict) -> None:
    root = Path(state["config_root"]) / "projects"
    matches = list(root.rglob(f'{state["session_id"]}.jsonl')) if root.is_dir() else []
    if len(matches) != 1:
        die(f"expected one transcript under {root}, found {len(matches)}")


def load_state(args, directory: Path, state_path: Path) -> dict:
    cwd = str(Path.cwd().resolve())
    root = Path(os.environ.get("CLAUDE_CONFIG_DIR", "~/.claude"))
    config_root = str(root.expanduser().resolve())
    if args.command == "start":
        if directory.exists() and any(directory.iterdir()):
            die(f"{directory} is not empty")
        directory.mkdir(parents=True, exist_ok=True)
        return {
            "config_root": config_root, "cwd": cwd, "effort": args.effort,
            "model": args.model, "session_id": str(uuid.uuid4()),
            "turn_complete": True,
        }
    if not state_path.is_file():
        die(f"missing {state_path}")
    state = json.loads(state_path.read_text(encoding="utf-8"))
    if state["cwd"] != cwd:
        die(f'recover from the original cwd: {state["cwd"]}')
    if state["config_root"] != config_root:
        die(f'restore CLAUDE_CONFIG_DIR to {state["config_root"]}')
    require_transcript(state)
    return state


def lock_directory(directory: Path):
    lock = (directory / ".lock").open("a+", encoding="utf-8")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        die(f"another manager is running for {directory}")
    return lock


def start_process(mode: str, state: dict, errors) -> subprocess.Popen:
    claude = shutil.which("claude")
    if not claude:
        die("claude executable not found")
    selector = ["--session-id" if mode == "start" else "--resume",
                state["session_id"]]
    command = [
        claude, "-p", *selector, "--model", state["model"], "--tools", TOOLS,
        "--permission-mode", "dontAsk", "--settings",
        '{"remoteControlAtStartup":false}', "--no-chrome",
        "--mcp-config", '{"mcpServers":{}}', "--strict-mcp-config",
        "--input-format", "stream-json", "--output-format", "stream-json",
        "--verbose",
    ]
    if state["effort"]:
        command += ["--effort", state["effort"]]
    process = subprocess.Popen(
        command, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
        stderr=errors, text=True, encoding="utf-8", bufsize=1,
    )
    assert process.stdin is not None and process.stdout is not None
    return process


def stop_process(process: subprocess.Popen, interrupted: bool) -> None:
    if process.stdin and not process.stdin.closed:
        process.stdin.close()
    if interrupted and process.poll() is None:
        process.terminate()
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()
