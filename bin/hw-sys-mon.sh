#!/bin/bash
#
# hw-sys-mon.sh
#
# Slack-iT - hw system monitor
#
# William PC Slack-iT Seattle 2019

HWMON=/sys/bus/platform/devices
BACKLIGHT_SOURCE=/sys/class/backlight/intel_backlight
POWERSTATE=$(cat /sys/class/power_supply/AC/online)
BATTERYCAPACITY=$(cat /sys/class/power_supply/BAT0/charge_full)
BATTERYLEVEL=$(cat /sys/class/power_supply/BAT0/charge_now)

function temperature_mon(){
  CPU_COUNT=4
  AWKCMD='{print substr ($0, 1, 2) "." substr ($0, 3, 1)}'

  echo "Thermal zone0: $(cat /sys/devices/virtual/thermal/thermal_zone0/temp | awk "$AWKCMD")"
  HWMON=$HWMON/coretemp.0/hwmon/hwmon0
  for i in {1..5}; do
    echo -n "$(cat $HWMON/temp$i\_label) - "
    cat $HWMON/temp$i\_input | awk "$AWKCMD"
  done
  echo "FAN rpm:" $(cat "/sys/devices/virtual/hwmon/hwmon0/fan1_input")
}

function brightness_mon(){
  BRIGHTNESS=$(cat $BACKLIGHT_SOURCE/brightness)
  MAX_BRIGHTNESS=$(cat $BACKLIGHT_SOURCE/max_brightness)
  BRIGHTNESS_LEVEL=$(cat $BACKLIGHT_SOURCE/brightness)

  echo $MAX_BRIGHTNESS / $BRIGHTNESS_LEVEL | awk -F "/" '{printf "%d / %d - %.2f%\n", $1, $2, (($2 / $1) * 100)}'
}

function battery_mon(){
  if [ "$1" == "-s" ]; then
    echo $BATTERYCAPACITY / $BATTERYLEVEL | awk -F "/" '{printf "%.2f%", (($2 / $1) * 100)}'
  else
    if [ "$POWERSTATE" == "1" ]; then 
      echo "power supply connected"; 
    else 
      echo "power supply disconnected"; 
    fi
    echo $BATTERYCAPACITY / $BATTERYLEVEL | awk -F "/" '{printf "%d / %d - %.2f%\n", $1, $2, (($2 / $1) * 100)}'
  fi
}

case $1 in
	temperature|brightness|battery)
	$1_mon
	;;
        *)
  	  temperature_mon
   echo --------------------------------
	  brightness_mon
   echo --------------------------------
	  battery_mon
	;;
esac

