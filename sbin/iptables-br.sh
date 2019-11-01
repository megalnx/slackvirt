
IFNET=qemubr0
NATIF=wlan0-sta
IPNET=192.168.10.0/24

RULES="
INPUT -i $IFNET -p udp -m udp --dport 53 -j ACCEPT
INPUT -i $IFNET -p tcp -m tcp --dport 53 -j ACCEPT
INPUT -i $IFNET -p udp -m udp --dport 67 -j ACCEPT
INPUT -i $IFNET -p tcp -m tcp --dport 67 -j ACCEPT

FORWARD -d $IPNET -o $IFNET -j ACCEPT -m conntrack --ctstate RELATED,ESTABLISHED 
FORWARD -s $IPNET -i $IFNET -j ACCEPT
FORWARD -i $IFNET -o $IFNET -j ACCEPT

FORWARD -d $IPNET -o $NATIF -m state --state RELATED,ESTABLISHED -j ACCEPT
#POSTROUTING -tnat -o wlan0-sta -j MASQUERADE
POSTROUTING -tnat -o wlan0-sta -s 192.168.10.0/24 -j MASQUERADE
POSTROUTING -tnat -o wlan0-sta -d 192.168.10.0/24 -j MASQUERADE

OUTPUT -o $IFNET -p udp -m udp --dport 68 -j ACCEPT

POSTROUTING -tnat -s $IPNET ! -d $IPNET -p tcp -j MASQUERADE --to-ports 1024-65535
POSTROUTING -tnat -s $IPNET ! -d $IPNET -p udp -j MASQUERADE --to-ports 1024-65535
POSTROUTING -tnat -s $IPNET ! -d $IPNET -j MASQUERADE
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

function stop() {
IFS='
'
count=0
for rule in $RULES; do	
  count=$((count+1))
  eval $(echo  "/usr/sbin/iptables -D $rule")
done
}


case $1 in
	stop)
		stop
		;;
	start)
		start
		;;
	restart)
		stop
		start
		;;
esac


