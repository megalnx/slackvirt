
IFNET=qemubr1
IPNET=192.168.20.0/24

function start(){

iptables -A FORWARD -s $IPNET -o $IFNET -j ACCEPT
iptables -A FORWARD -d $IPNET -o $IFNET -j ACCEPT
iptables -A FORWARD -d $IPNET -o wlan0-sta -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $IFNET -o $IFNET -j ACCEPT

iptables -t nat -A POSTROUTING -o wlan0-sta -j MASQUERADE

}

function stop() {
iptables -D FORWARD -s $IPNET -o $IFNET -j ACCEPT
iptables -D FORWARD -d $IPNET -o $IFNET -j ACCEPT
iptables -D FORWARD -d $IPNET -o wlan0-sta -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -D FORWARD -i $IFNET -o $IFNET -j ACCEPT

iptables -t nat -D POSTROUTING -o wlan0-sta -j MASQUERADE

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


