#!/bin/bash
#
# Generate a fluxbox menu for libvirt
# 
# William PC, Seattle US 2019
#


[ "$#" == "0" ] && echo "arg: slackvirt|libvirt" && exit

if [ "$1" == "slackvirt" ]; then
echo "[submenu] (slackvirt)"
echo "  [exec]  (start all) { /usr/local/etc/rc.d/rc.slackvirt start }"
echo "  [exec]  (stop all) { /usr/local/etc/rc.d/rc.slackvirt stop }"
echo "[separator]"
echo "  [submenu]  (server vm)"
echo "  [exec]  (ssh) { xterm -e 'ssh root@server' }"
echo "  [separator]"
echo "  [exec]  (start) { slackware-qemu-vmserver.sh start /usr/local/etc/slackvirt/server.qemu }"
echo "  [exec]  (stop) { slackware-qemu-vmserver.sh stop /usr/local/etc/slackvirt/server.qemu }"
echo "  [separator]"
echo "  [exec]  (qemu monitor) { xterm -T server-monitor.sock -e 'minicom -D unix#/tmp/server-monitor.sock' }"
echo "  [end]"
echo "  [submenu]  (desktop vm)"
echo "  [exec]  (ssh) { xterm -e 'ssh root@desktop' }"
echo "  [separator]"
echo "  [exec]  (start) { slackware-qemu-vmserver.sh start /usr/local/etc/slackvirt/desktop.qemu }"
echo "  [exec]  (stop) { slackware-qemu-vmserver.sh stop /usr/local/etc/slackvirt/desktop.qemu }"
echo "  [separator]"
echo "  [exec]  (qemu monitor) { xterm -T desktop-monitor.sock -e 'minicom -D unix#/tmp/desktop-monitor.sock' }"
echo "  [end]"
echo "  [exec]  (qemu ls) { xterm -T "qemu-ls" -geometry 24x10 -e 'slackware-qemu-vmserver.sh list; sleep 4' }"
echo "[end]"
fi

if [ "$1" == "libvirt" ]; then
DOMAINS=$(virsh list --name --all | sort --ignore-case)
echo "[submenu] (libvirt)"
echo "  [exec]   (virt-manager) {virt-manager}"
echo "[separator]"
echo "  [exec]   (spice gtk) {spicy}"
echo "  [exec]   (shutdown all vms) {for vm in $(virsh list --state-running --name); do virsh shutdown $vm ;done}"
echo "  [exec]   (tmux virsh) {xterm -geometry 140x32 -T 'tmux virt' -e \"tmux new-session 'virsh' -d \; split-window -v -d '/bin/bash' \; split-window -h -d 'watch -n 4 virsh list --state-running' \; attach -d\"}"
echo "[separator]"
for domain in $DOMAINS; do
  echo "[submenu] ($domain)"
  echo "[separator]"
  echo "  [exec]   (start) {virsh start $domain}"
  echo "  [exec]   (reboot) {virsh reboot $domain}"
  echo "  [exec]   (shutdown) {virsh shutdown $domain}"
  echo "[end]"
done
echo "[end]"
fi
