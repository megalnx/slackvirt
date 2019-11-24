WLANAP=wlan0-ap
LANIP=192.168.77.0/24

RULES="
FORWARD -d $LANIP -o $WLANAP -j ACCEPT -m state --state RELATED,ESTABLISHED
FORWARD -s $LANIP -i $WLANAP -j ACCEPT
FORWARD -s $LANIP -d 192.168.20.0/24 -i $WLANAP -j ACCEPT  -m state --state RELATED,ESTABLISHED
FORWARD -s 192.168.77.20 -i $WLANAP -j ACCEPT
FORWARD -s 192.168.77.20 -d 192.168.40.0/24 -i $WLANAP -j ACCEPT  -m state --state RELATED,ESTABLISHED
FORWARD -i $WLANAP -o $WLANAP -j ACCEPT
FORWARD -i $WLANAP -o qemubr1 -j ACCEPT
FORWARD -i qemubr1 -o $WLANAP -j ACCEPT

FORWARD -s 192.168.20.0/24 -o qemubr1 -j ACCEPT
FORWARD -s $LANIP -i qemubr1 -j ACCEPT



FORWARD -d $LANIP -o qemubr1 -m state --state RELATED,ESTABLISHED -j ACCEPT
"

RULES_NAT="
POSTROUTING -tnat -s $LANIP ! -d $LANIP -p tcp -j MASQUERADE --to-ports 1024-65535
POSTROUTING -tnat -s $LANIP ! -d $LANIP -p udp -j MASQUERADE --to-ports 1024-65535
POSTROUTING -tnat -s $LANIP ! -d $LANIP -j MASQUERADE
"

function start(){
IFS='
'
count=0
for rule in $RULES; do	
  count=$((count+1))
  eval $(echo  "/usr/sbin/iptables -A $rule")
done
}

function start_nat(){
IFS='
'
count=0
for rule in $RULES_NAT; do
  count=$((count+1))
  eval $(echo  "/usr/sbin/iptables -A $rule")
done

#iptables -t nat -A POSTROUTING -o virbr0 -j MASQUERADE
#iptables -t nat -A POSTROUTING -o wlan0_ap -j MASQUERADE

}

function stop(){
IFS='
'
count=0
for rule in $RULES; do
  count=$((count+1))
  eval $(echo  "/usr/sbin/iptables -D $rule")
done
}

function stop_nat(){
IFS='
'
count=0
for rule in $RULES_NAT ; do
  count=$((count+1))
  eval $(echo  "/usr/sbin/iptables -D $rule")
done
#iptables -t nat -D POSTROUTING -o virbr0 -j MASQUERADE
#iptables -t nat -D POSTROUTING -o wlan0_ap -j MASQUERADE

}

case $1 in
	start|stop)
		$1
#		$1_nat
		;;
	start_nat|stop_nat)
		$1
		;;
	restart)
		stop; stop_nat
		start; start_nat
		;;
esac

