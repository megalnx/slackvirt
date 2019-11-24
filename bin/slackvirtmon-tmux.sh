#!/bin/bash

function down(){
tmux new-session -n "sys-mon" -s "sys-mon" -d '/bin/bash'
tmux split-window -v 'htop -d20'
#tmux split-window -h -p 30 'watch -n 4 virsh list --all'
tmux split-window -h -p 30 'watch -n 4 slackware-qemu-vmserver.sh list'
tmux split-window -v 'watch -n 4 /usr/local/bin/hw-sys-mon.sh brightness'
tmux split-window -h '/bin/bash'
tmux clock-mode -t 4
tmux selectp -t 3
tmux split-window -v 'watch -n 4 /usr/local/bin/hw-sys-mon.sh battery'
tmux selectp -t 0
}

function up(){
tmux new-session -n "sys-mon" -s "sys-mon" -d 'htop -d20'
tmux split-window -v -p 40 '/bin/bash'
#tmux split-window -h -p 30 'watch -n 4 virsh list --all'
tmux split-window -h -p 30 'watch -n 4 slackware-qemu-vmserver.sh list'
tmux split-window -v 'watch -n 4 /usr/local/bin/hw-sys-mon.sh brightness'
tmux split-window -h '/bin/bash'
tmux clock-mode -t 4
tmux selectp -t 3
tmux split-window -v 'watch -n 4 /usr/local/bin/hw-sys-mon.sh battery'
#tmux split-window -v 'watch -n 4 /usr/local/bin/dialog-ctrl.sh'
tmux selectp -t 0
}

TMUX_SESSION=$(tmux ls)
if [ "$TMUX_SESSION" == "no server running" ]; then
  echo yes
else 
  tmux attach-session -t sys-mon
fi

#down
up

# disk
tmux new-window -n "disk-mon" '/bin/bash'
tmux split-window -v 'watch -n 4 iostat'
tmux split-window -h 'watch -n 10 df -h'
tmux selectp -t 0

# net-mon
tmux new-window -n "net-mon" 'iftop -i eth0'
tmux split-window -v 'iftop -i wlan0-sta'
tmux split-window -h 'iftop -i wlan0-ap'
tmux selectp -t 0

# netvirt-mon
tmux new-window -n "netvirt-mon" 'iftop -i qemubr0'
tmux split-window -v 'iftop -i qemubr1'
tmux split-window -h 'iftop -i qemubr2'
tmux selectp -t 0

# command 
tmux new-window -n "command" '/bin/bash'
tmux split-window -h '/bin/bash'
tmux split-window -v '/bin/bash'
tmux selectp -t 0
tmux display-panes

# minicom
#tmux split-window -h '/bin/bash ~/bin/xterm-console-minicom.sh babylon'

# ssh windows
tmux new-window -n "ssh-server" '/bin/bash'
tmux new-window -n "ssh-desktop" '/bin/bash'
tmux new-window -n "ssh" '/bin/bash'
tmux selectw -t 0
tmux selectp -t 1
tmux -2 attach-session -d
