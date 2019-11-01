#!/bin/bash

IFNAME=wlan0-sta
SNAME="sys-mon"

ACTIVE_SESSION=$(tmux list-session | awk -F ":" '{print $1}')

if [ "$ACTIVE_SESSION" != "$SNAME" ]; then
  tmux new-session -n "$(hostname)-$(fgconsole)-$SNAME" -s $SNAME -d '/bin/bash'
  tmux new-window -t $SNAME -n "wifi" -d '/bin/bash'
else
  tmux new-window -n "wifi" -d '/bin/bash'
  sleep 1
  tmux select-window -t "wifi"
fi

tmux split-window -v -p 60 "watch -t -n 4 rfkill list"
tmux selectp -t 1
tmux split-window -h "watch -t -n 4 iwconfig $IFNAME"
tmux selectp -t 1
tmux split-window -v -p 60 "watch -t -n 4 ifconfig $IFNAME"
tmux selectp -t 3
tmux split-window -v -p 60 'iftop -i wlan0-sta'
tmux -2 attach-session -d
