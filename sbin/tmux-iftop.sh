#!/bin/bash

SNAME="sys-mon"

ACTIVE_SESSION=$(tmux list-session | awk -F ":" '{print $1}')

if [ "$ACTIVE_SESSION" != "$SNAME" ]; then
  tmux new-session -d 'iftop -i qemubr0'
else
  tmux new-window -d 'iftop -i qemubr0'
fi

tmux split-window -v 'iftop -i qemubr1'
tmux split-window -h 'iftop -i qemubr2'
#tmux -2 attach-session -d

