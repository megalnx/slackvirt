#!/bin/bash

tmux new-session -n "netwatch" -s "netwatch" -d 'netwatch -e qemubr0'
tmux split-window -v 'netwatch -e qemubr1'
tmux split-window -h 'netwatch -e qemubr2'
tmux -2 attach-session -d
