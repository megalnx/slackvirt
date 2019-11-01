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
 $0 status | head -n1 | grep -q "not running"
 if [ "$?" == "1" ]; then
   echo "VM $VMNAME already running."
   exit
 fi

 $VMCMD -name guest=$VMNAME \
    -m $MEMORY \
    $MACHINE $CPU \
    -chardev socket,id=monitor,path=/tmp/$VMNAME-monitor.sock,server,nowait -monitor chardev:monitor \
    -chardev socket,id=serial0,path=/tmp/$VMNAME-console.sock,server,nowait -serial chardev:serial0 \
    $QEMU_CONTROLLERS \
    $QEMU_SERIAL \
    $QEMU_VIDEO \
    $QEMU_DISK \
    $QEMU_AUDIO \
    $QEMU_NET \
    $QEMU_EXTRA \
    $QEMU_SPICE \
    $QEMU_MOUSE &
}

function stop_vm(){
  POWERDOWN_CMD="system_powerdown"
  echo "Shutdown VM: $VMNAME"
  sleep 0.4
  i=0;

  minicom -D "unix#/tmp/$VMNAME-monitor.sock" \
          -C /root/$VMNAME-monitor.minicom \
	  -S /usr/local/etc/minicom/shutdown-vms.sh > /dev/null &
  while [ "$(pgrep -f "$VMCMD*.*guest=$VMNAME")" != "" ]; do
    sleep 0.4; echo -n "."
#    i=( i + 1 );
#    [ "$i" == "20" ] && break; stop_vm
  done
  echo ""
}

function resume_vm(){
  POWERDOWN_CMD="cont"
  echo "Resume VM: $VMNAME"
  sleep 0.4
  i=0;

  minicom -D "unix#/tmp/$VMNAME-monitor.sock" \
          -C /root/$VMNAME-monitor.minicom \
	  -S /usr/local/etc/minicom/resume-vms.sh > /dev/null &
  echo ""
}

function pause_vm(){
  POWERDOWN_CMD="cont"
  echo "Pause VM: $VMNAME"
  sleep 0.4
  i=0;

  minicom -D "unix#/tmp/$VMNAME-monitor.sock" \
          -C /root/$VMNAME-monitor.minicom \
	  -S /usr/local/etc/minicom/pause-vms.sh > /dev/null &
  echo ""
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
	resume)
	  [ "$(pgrep -f "$VMCMD*.*guest=$VMNAME")" == "" ] && exit
  	  resume_vm
	  	;;
	pause)
	  [ "$(pgrep -f "$VMCMD*.*guest=$VMNAME")" == "" ] && exit
  	  pause_vm
		;;
	configure)
	  cfg_vm
		;;
	status)
  	  if [ "$(pgrep -f "$VMCMD*.*guest=$VMNAME")" == "" ]; then
	    echo "VM not running"
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


