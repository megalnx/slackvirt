# NOTE: Slackware 14.1 - doesn't allow cpu disabling

function vms_mode_battery(){
  CFG_FILE=/usr/local/etc/slackvirt/server.qemu /usr/local/sbin/vm-cpu-hotplug.sh disable
#  CFG_FILE=/usr/local/etc/slackvirt/desktop.qemu /usr/local/sbin/vm-cpu-hotplug.sh disable
}

function vms_mode_ac(){
  CFG_FILE=/usr/local/etc/slackvirt/server.qemu /usr/local/sbin/vm-cpu-hotplug.sh enable
#  CFG_FILE=/usr/local/etc/slackvirt/desktop.qemu /usr/local/sbin/vm-cpu-hotplug.sh enable
}

case $1 in
    true) vms_mode_battery ;;
    false) vms_mode_ac ;;
    *) exit $NA ;;
esac

exit 0
