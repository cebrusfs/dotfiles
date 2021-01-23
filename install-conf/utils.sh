function log {
    COLOR='\033[1;35m'
    NO_COLOR='\033[0m'
    printf "${COLOR}>> ${1}${NO_COLOR}\n"
}

function error {
    COLOR='\033[1;31m'
    NO_COLOR='\033[0m'
    printf "${COLOR}[ERROR] ${1}${NO_COLOR}\n"
    exit 1
}

function pushd () {
    command pushd "$@" > /dev/null
}

function popd () {
    command popd "$@" > /dev/null
}

function is_osx() {
    if [[ "$OSTYPE" == darwin* ]]; then
        true
    else
        false
    fi
}

function is_linux() {
    if [[ "$OSTYPE" == linux* ]]; then
        true
    else
        false
    fi
}

function check_command() {
    if command -v "$1" &> /dev/null; then
        true
    else
        false
    fi
}

function ask_skip {
    local name=$1
    local time=${2:-5}
    if read -t $time -p $'Hit ENTER to skip \e[1;37m'"$name"$'\e[m or wait '"$time"$' seconds'; then
        return 0
    else
        echo
        return 1
    fi
}

function run_in_tmux {
    local session_name=$1; shift
    local name=$1; shift
    local cmd=$1; shift
    tmux new-session -d -n "$name" -s "$session_name" "($cmd) || (echo -e '\e[1;33mCommand fail QQ\e[m'; $SHELL)"
    while [[ $# -ne 0 ]]; do
        name=$1; shift
        cmd=$1; shift
        tmux new-window -n "$name" "($cmd) || (echo -e '\e[1;33mCommand fail QQ\e[m'; $SHELL)"
    done
    tmux attach-session
}
