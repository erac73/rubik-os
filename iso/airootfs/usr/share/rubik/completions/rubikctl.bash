# Bash completion for rubikctl (Rubik OS orchestrator)
# Source this file: source /usr/share/rubik/completions/rubikctl.bash

_rubikctl() {
    local cur prev words cword
    _init_completion || return

    local commands="status health validate cell face"
    local cell_actions="start stop rotate status"
    local face_actions="rotate status"

    # Get cell names from filesystem
    local cells=""
    if [[ -d /usr/lib/rubik/cells ]]; then
        cells=$(ls /usr/lib/rubik/cells/*.sh 2>/dev/null | xargs -n1 basename -s .sh)
    fi

    case $cword in
        1)
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            ;;
        2)
            case "${words[1]}" in
                cell) COMPREPLY=($(compgen -W "$cell_actions" -- "$cur")) ;;
                face) COMPREPLY=($(compgen -W "$face_actions" -- "$cur")) ;;
            esac
            ;;
        3)
            case "${words[1]}" in
                cell) COMPREPLY=($(compgen -W "$cells" -- "$cur")) ;;
                face) COMPREPLY=($(compgen -W "0 1 2 3 4 5" -- "$cur")) ;;
            esac
            ;;
    esac
}

complete -F _rubikctl rubikctl rubikd
