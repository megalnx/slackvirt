PING_CMD="ping -I qemubr2 -i 1 -W 2 -c 2 -t 2 -q"
$PING_CMD server-ctl > /dev/null
if [ $? -eq 0 ]; then
  echo server - online
else 
  echo server - offline
fi
$PING_CMD desktop-ctl > /dev/null
if [ $? -eq 0 ]; then
  echo desktop - online
else 
  echo desktop - offline
fi

