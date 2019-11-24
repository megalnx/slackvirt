#!/bin/bash
#
#
# William PC Slack-iT Seattle 2019

###########################################
# Basic VM settings
###########################################
VMNAME=${VMNAME:-testi}
MEMORY=${MEMORY:-3G}
MACHINE=${MACHINE:-"-machine pc-i440fx-3.1,usb=off"}
CPU="-cpu host -smp 4,sockets=1,cores=2,threads=2"
DISK=
MEDIA=${MEDIA:-"/media/cdrom"}

###########################################

###########################################
# QEMU settings
###########################################
VMCMD=${QEMU_CMD:-"qemu-system-x86_64 -enable-kvm"}
QMP_PATH=/usr/local/share/qemu/qmp


CFG_FILE=$2

if [ ! -z "$CFG_FILE" ]; then
  source "$CFG_FILE"
fi

# --------------------------------------- #

function cfg_vm(){
  echo "Hardware"
  echo -n "Memory: "; read MEMORY
}

function install_vm(){
#mkfifo /tmp/guest.in /tmp/guest.out
# no video
# curses or nographic
  $VMCMD \
    -m $MEMORY -cdrom $MEDIA -boot d -nographic \
    -serial pipe:/tmp/guest &
  expect /usr/local/share/expect/slackware-install_serial.exp pipe
#tmux send-keys -t 1 C-z 'cat /tmp/guest.out' Enter 
}

function start_vm(){
 $0 status $CFG_FILE | head -n1 | grep -q "VM not running"
 if [ "$?" == "1" ]; then
   echo "VM $VMNAME already running."
   exit
 fi

#    -chardev socket,id=monitor,path=/tmp/$VMNAME-monitor.sock,server,nowait -monitor chardev:monitor \

 VMCMD="$VMCMD -name guest=$VMNAME \
    -m $MEMORY \
    $MACHINE $CPU $SMP \
    -qmp unix:/tmp/$VMNAME-monitor.sock,server,nowait -monitor stdio \
    -chardev socket,id=serial0,path=/tmp/$VMNAME-console.sock,server,nowait -serial chardev:serial0 \
    $QEMU_CONTROLLERS \
    $QEMU_SERIAL \
    $QEMU_VIDEO \
    $QEMU_DISK \
    $QEMU_AUDIO \
    $QEMU_NET \
    $QEMU_EXTRA \
    $QEMU_SPICE \
    $QEMU_MOUSE"

  if [ ! -f "/srv/qemu/$VMNAME-statefile.gz" ]; then
    $VMCMD &
  else
    echo "gzip -c -d /srv/qemu/$VMNAME-statefile.gz | $VMCMD -incoming \"exec: cat\" "
  fi
}

function stop_vm(){
  POWERDOWN_CMD="system_powerdown"
  SOCKET=/tmp/$VMNAME-monitor.sock
  echo "Shutdown VM: $VMNAME"
  sleep 0.4
  i=0;

#  minicom -D "unix#$SOCKET" \
#          -C /root/$VMNAME-monitor.minicom \
#	   -S /usr/local/etc/minicom/shutdown-vms.sh > /dev/null &
  echo "$POWERDOWN_CMD" | $QMP_PATH/qmp-shell -p $SOCKET > /dev/null &

  while [ "$(pgrep -f "$VMCMD*.*guest=$VMNAME")" != "" ]; do
    sleep 0.5; echo -n "."
    i=$(( i + 1 ));
    if [ "$i" == "240" ];then
      echo "force off"
      echo "quit" | $QMP_PATH/qmp-shell -p $SOCKET > /dev/null &      
      sleep 0.4
      kill -9 $(pgrep -f "$VMCMD*.*guest=$VMNAME") &> /dev/null
      break
    fi
  done
  echo ""
}

function wakeup_vm(){
  POWERDOWN_CMD="system_wakeup"
  SOCKET=/tmp/$VMNAME-monitor.sock
  echo "Wakeup VM: $VMNAME"
  sleep 0.4
  i=0;

#  minicom -D "unix#$SOCKET" \
#          -C /root/$VMNAME-monitor.minicom \
#	   -S /usr/local/etc/minicom/wakeup-vms.sh > /dev/null &

  echo "$POWERDOWN_CMD" | $QMP_PATH/qmp-shell -p $SOCKET > /dev/null &
  echo ""
}

function resume_vm(){
  POWERDOWN_CMD="cont"
  SOCKET=/tmp/$VMNAME-monitor.sock
  echo "Resume VM: $VMNAME"
  sleep 0.4
  i=0;

#  minicom -D "unix#$SOCKET" \
#          -C /root/$VMNAME-monitor.minicom \
#	   -S /usr/local/etc/minicom/resume-vms.sh > /dev/null &

  echo "$POWERDOWN_CMD" | $QMP_PATH/qmp-shell -p $SOCKET > /dev/null &
  echo ""
}

function pause_vm(){
  POWERDOWN_CMD="cont"
  SOCKET=/tmp/$VMNAME-monitor.sock
  echo "Pause VM: $VMNAME"
  sleep 0.4
  i=0;

#  minicom -D "unix#$SOCKET" \
#          -C /root/$VMNAME-monitor.minicom \
#	   -S /usr/local/etc/minicom/pause-vms.sh > /dev/null &
  
  echo "$POWERDOWN_CMD" | $QMP_PATH/qmp-shell -p $SOCKET > /dev/null &
  echo ""
}

function save_vm(){
  pause_vm
  echo "Save VM state: $VMNAME"
  sleep 0.4
  i=0;

  VMNAME=$VMNAME minicom -D "unix#/tmp/$VMNAME-monitor.sock" \
          -C /root/$VMNAME-monitor.minicom \
	  -S /usr/local/etc/minicom/save-vms.sh > /dev/null &
  echo ""
}

function load_vm(){
  POWERDOWN_CMD="cont"
  echo "Load VM state: $VMNAME"
  sleep 0.4
  start_vm
}

function list_vms(){
  # this shows all vms running by qemu
  # using ps its necessary to include "--cols" to restrict the output widgth
  # otherwise is unable to print the output at small terminal windows.
  #VMS=$(pgrep -a "qemu-" | grep -o "guest=[aA-zZ]*[aA-zZ]" | awk -F"=" '{printf "%s\n", $2}')

  VMS=$(pgrep -f "qemu-*.*guest=[aA-zZ]")
  if [ "$VMS" == "" ]; then
    echo " - "
  else
    echo "%cpu  %mem - vm"
    echo " ------------ "
    for vm in $VMS; do
      VM_STATUS=$(ps -ho tty $vm)
      VM_NAME=$(ps -q "$vm" -ho cmd --cols 1024 | grep -o "guest=[aA0-zZ9]*[aA0-zZ9]" | awk -F"=" '{printf "%s\n", $2}')
      VM_CPU=$(ps -q "$vm" -ho %cpu)
      VM_MEM=$(ps -q "$vm" -ho %mem)
#      if [ "$VM_STATUS" == "?" ]; then
#        echo "$VM_NAME" - "$VM_CPU%" - "stopped"
#      else
#
#      fi
        echo "$VM_CPU% $VM_MEM - $VM_NAME"
    done
  fi
}

case $1 in
	install)
	  $0 status
	  install_vm || exit
		;;
	start)
	  start_vm || exit
		;;
	stop)
	  [ "$(pgrep -f "$VMCMD*.*guest=$VMNAME")" == "" ] && exit
  	  stop_vm
	  	;;
	wakeup)
	  [ "$(pgrep -f "$VMCMD*.*guest=$VMNAME")" == "" ] && exit
  	  wakeup_vm
	  	;;
	resume)
	  [ "$(pgrep -f "$VMCMD*.*guest=$VMNAME")" == "" ] && exit
  	  resume_vm
	  	;;
	pause)
	  [ "$(pgrep -f "$VMCMD*.*guest=$VMNAME")" == "" ] && exit
  	  pause_vm
	  	;;
	save)
	  [ "$(pgrep -f "$VMCMD*.*guest=$VMNAME")" == "" ] && exit
  	  save_vm
	  	;;
	load)
	  [ "$(pgrep -f "$VMCMD*.*guest=$VMNAME")" == "" ] && exit
  	  load_vm
		;;
	configure)
	  cfg_vm
		;;
	status)
  	  if [ "$(pgrep -f "$VMCMD*.*guest=$VMNAME")" == "" ]; then
	    echo "VM not running"
	    exit
          else
	    echo "VM running"
	    ps -o pid,%cpu,%mem,cmd $(pgrep -f "$VMCMD*.*guest=$VMNAME")
	  fi
		;;
	list)
		list_vms
		;;

	*)
  	  echo "$0 install|start|stop|configure|status"
		;;
esac


