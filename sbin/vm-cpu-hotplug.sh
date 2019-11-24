# maxcpus=6
CPU_MODEL=${CPU:-Skylake-Client-IBRS}
SOCKET=${SOCKET:-/tmp/desktop-monitor.sock}
QMP_PATH=/usr/local/share/qemu/qmp

if [ ! -z $CFG_FILE ];then
  VMNAME=$(grep "VMNAME=" $CFG_FILE | awk -F= '{print $2}')
  CPU_MODEL=$(grep "CPU=" $CFG_FILE | awk '{print $2}' | awk -F, '{print $1}' | tr -d \")
  SMP_TOPOLOGY=$(eval echo $(grep "SMP=" $CFG_FILE))
  CPUS=$(echo "$SMP_TOPOLOGY" | grep -o "\-smp [0-9,0-9]" | awk '{print $2}')
  MAX_CPUS=$(echo "$SMP_TOPOLOGY" | grep -o "\maxcpus=[0-9,0-9]" | awk -F= '{print $2}')
  SOCKET=/tmp/$VMNAME-monitor.sock
fi

echo $CPU_MODEL - $MAX_CPUS - $CPUS
echo $SOCKET

#qemu-monitor.minicom
#echo "device_add driver=$CPU_MODEL,socket-id=1,die-id=0,core-id=0,thread-id=0,id=cpu4"
#echo "device_add driver=$CPU_MODEL,socket-id=1,die-id=0,core-id=0,thread-id=1,id=cpu5"

#qmp-shell

function enable_cpus(){
  cpu_count=$CPUS
  while [ $cpu_count -lt $MAX_CPUS ]; do
    echo Adding CPU: $((cpu_count-$CPUS)) - cpu-id=$cpu_count
    echo "device_add id=cpu-$cpu_count driver=$CPU_MODEL-x86_64-cpu die-id=0 socket-id=1 core-id=$((cpu_count-$CPUS)) thread-id=0" | $QMP_PATH/qmp-shell -p -v $SOCKET
    cpu_count=$((cpu_count+1))
#  echo "device_add id=cpu-5 driver=$CPU_MODEL-x86_64-cpu die-id=0 socket-id=1 core-id=0 thread-id=1" | $QMP_PATH/qmp-shell -p -v $SOCKET
  done
}

function disable_cpus(){
  cpu_count=$((MAX_CPUS-1))
  while [ $cpu_count -gt $((CPUS-1)) ]; do
    echo Removing CPU: $((cpu_count-$CPUS)) - cpu-id=$cpu_count
    echo "device_del id=cpu-$cpu_count" | $QMP_PATH/qmp-shell -p -v $SOCKET
    cpu_count=$((cpu_count-1))
  done
  #  echo "device_del id=cpu-4" | $QMP_PATH/qmp-shell -p -v $SOCKET
}

case $1 in
	enable)
		enable_cpus
		;;
	disable)
		disable_cpus
		;;
esac
