
#!/bin/bash
#
#   This script will Improve the efficiency of tmux usage
#   1. tmuxl:tmux ls
#   2. tmuxa:tmux attach -t name
#   3. tmuxk: tmux kill-session -t name1, name2,...
#

tmux_ls(){
    tmux ls
}

tmux_attach(){
    if [ $# -ne 1 ];then
        echo "Failed: too session name"
        return
    fi
    tmux attach -t $1
}

tmux_new(){
    if [ $# -ne 1 ];then
        echo "Failed: too session name"
        return
    fi
    tmux new -s $1
}

tmux_kill(){
    if [ $# -lt 1 ];then
        echo "Failed: too less name"
        return
    fi
    for name in $@
    do
        tmux kill-session -t $name
    done
}

while [ -n "$1" ]
    do
        case "$1" in
            -l|--ls)
                tmux_ls
                exit
                ;;
            -n|--new)
                shift
                tmux_new $@
                exit
                ;;
            -a|--attach)
                shift
                tmux_attach $@
                exit
                ;;
            -k|--killl)
                shift
                tmux_kill $@
                exit
                ;;
            *)
                echo -e "\Failed: nerror args!\n"
                exit
                ;;
        esac
    done

