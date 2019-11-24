#!/bin/bash
#
# Slack-iT William PC, Seattle 2019
#

IWFACE=${1:-wlan}
RFNAME=$(rfkill list $IWFACE | awk -F": " '{print $3}')

if [ "$RFNAME" == "" ]; then
  exit
fi

CSTATE=$(rfkill list $IWFACE | grep "Soft blocked" | awk '{print $3}')

if [ "$RFNAME" == "Wireless LAN" ]; then
  ICON="network-wireless"
elif [ "$RFNAME" == "Bluetooth" ]; then 
  ICON="bluetooth-symbolic"
fi

if [ "$CSTATE" == "no" ]; then
  rfkill block $IWFACE
  echo $RFNAME off
  notify-send -i $ICON "$RFNAME" "off"
else
  rfkill unblock $IWFACE
  echo $RFNAME on
  notify-send -i $ICON "$RFNAME" "on"
fi
