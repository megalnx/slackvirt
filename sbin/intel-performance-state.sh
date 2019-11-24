#!/bin/bash
#
# William PC, Slack-iT Seattle 2019
#

STATES="powersave|performance"
CURRENT_STATE=$(cpufreq-info -p | awk {'print $3'})
echo "current governor: $CURRENT_STATE"

DISPLAY=:0.0

function cpuset_gp(){
  for cpu_n in $(lscpu -b -e=cpu | tail -n +2); do
    cpufreq-set -g $STATE -c $cpu_n
  done
}

case $1 in
	performance|powersave)
	  STATE=$1
          ;;
	 true) STATE=powersave  ;;
	 false) STATE=performance  ;;
         *)
  	  STATE=$(echo "$STATES" | sed "s/$CURRENT_STATE//" | tr -d "|")
	  ;;
esac

echo cpuset_gp $STATE
cpuset_gp "$1"
if [ "$STATE" == "performance" ]; then
  ICON=/usr/local/share/icons/icon.png
else
  ICON=/usr/local/share/icons/icon.png
fi
DISPLAY=$DISPLAY notify-send -t 3000 -i $ICON "CPU" "Setting $STATE mode"
tmux display-message "CPU - Setting $STATE mode" & 

