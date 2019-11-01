IF_NAME0=qemubr
IF_NAME1=qemubr
IF_NAME2=qemubr


function pingto(){
  PING_CMD="ping -I $1 -i 1 -W 1 -c 2 -t 1 -q"
  $PING_CMD $2 > /dev/null
  if [ $? -eq 0 ]; then
    echo $2 $1 - online
  else 
    echo $2 $1 - offline
  fi
}


pingto $IF_NAME0\0 192.168.10.1
pingto $IF_NAME0\0 192.168.10.2
pingto $IF_NAME0\0 192.168.10.3

pingto $IF_NAME1\1 192.168.20.1
pingto $IF_NAME1\1 192.168.20.2
pingto $IF_NAME1\1 192.168.20.3

pingto $IF_NAME2\2 192.168.30.1
pingto $IF_NAME2\2 192.168.30.2
pingto $IF_NAME2\2 192.168.30.3


