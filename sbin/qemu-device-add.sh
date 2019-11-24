SOCKET=/tmp/desktop-monitor.sock
QMP_PATH=/usr/local/share/qemu/qmp

USB_DEVICES="
# webcam
driver=usb-host hostbus=1 hostaddr=3 bus=usb0.0 port=2
# bluetooth
driver=usb-host hostbus=1 hostaddr=4 bus=usb0.0 port=3"

function get_device(){
IFS='
'
  for usb_dev in $USB_DEVICES; do
    echo "$usb_dev" | grep -v "^#"

  done
}

function pluggin_usb(){
IFS='
'
count=0
  for i in $(get_device); do
    echo "device_add id=usb-hostdev-$count $i"
    count=$((count+1))
    echo "device_add id=usb-hostdev-$count $i" | $QMP_PATH/qmp-shell -p -v $SOCKET
  done
}

function unplug_usb(){
IFS='
'
count=0
  for i in $(get_device); do
    echo "removing device $i"
    count=$((count+1))
    echo "device_del id=usb-hostdev-$count" | $QMP_PATH/qmp-shell -p -v $SOCKET
  done
}

case $1 in
	enable)
		pluggin_usb
		;;
	disable)
		unplug_usb
		;;
esac

