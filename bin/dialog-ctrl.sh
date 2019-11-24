#!/bin/bash
#
# Dialog control
#
# William PC Slack-iT Seattle 2019
#

BRIGHTNESS_CTR=/sys/class/backlight/intel_backlight/brightness
MAX_BRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/max_brightness)

MIXER_CTR=pamixer
MAX_VOLUME=100
STEP_VOLUME=10

DIALOG=dialog

function pa_control(){
while true; do
  NOW_VOLUME=$(pamixer --get-volume)
  $DIALOG --rangebox "Pulseadio volume" 2 32 $STEP_VOLUME $MAX_VOLUME $NOW_VOLUME 2> /tmp/dialog-ctl_pavolume
  [ "$?" == 1 ] && break
  pamixer --set-volume $(cat /tmp/dialog-ctl_pavolume)
  sleep 0.2
done
}
 
function rf_control(){
IWFACES=$(rfkill list | grep -o "^[0-9]:")
RFLIST=""
while true; do
  for rif in $IWFACES; do
    dev=$(rfkill list $rif | head -n1 | awk -F ": " '{print $1":"$2}')
    dev_name="$(rfkill list $rif | awk -F ":" '{print $3}')"
    dev_status="$(rfkill list $rif | head -n2 | awk -F ":" '{print $2}' | tail -n1 | sed 's/no/on/g' | sed 's/yes/off/g' )"
    RFLIST+="\"$dev\" \"$dev_name\" $dev_status "
  done
  eval "$DIALOG --checklist \"Radio control\" 20 46 5 $RFLIST 2> /tmp/dialog-ctl_radioctl"
  [ "$?" == 1 ] && break
  cat /tmp/dialog-ctl_radioctl
  RFLIST=""
  for dev in $(cat /tmp/dialog-ctl_radioctl); do
     toogle-wifi.sh $dev
     sleep 1.2
  done
done
#  echo " "; rfkill list | dialog --programbox "rfkill list" 18 40 
}

function brightness_control(){
while true; do
  NOW_BRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/actual_brightness)
  $DIALOG --rangebox "Display brightness" 2 32 400 $MAX_BRIGHTNESS $NOW_BRIGHTNESS 2> /tmp/dialog-ctl_brightness
  [ "$?" == 1 ] && break
  echo $(cat /tmp/dialog-ctl_brightness) > $BRIGHTNESS_CTR
  sleep 0.3
done
}

function menu_show(){
while true; do
  $DIALOG --menu "Slack-iT - dialog-ctl" 10 32 4 "pa_control" "audio control" "rf_control" "radio" "brightness_control" "brightness" 2> /tmp/dialog-ctl
  if [ "$?" == "1" ]; then
    break
  elif [ "$?" != "0" ]; then
    $(cat /tmp/dialog-ctl)
  fi
  sleep 0.3
done
}

function widgets(){
dialog \
	        --begin 2 2 --yesno "Continue?" 0 0 \
   --and-widget --begin 4 4 --calendar "Date:" 4 40 $(date +%d) $(date +%m) $(date +%y)
}

function calendar(){
  dialog --calendar "Date:" 4 40 $(date +%d) $(date +%m) $(date +%y)
}

function form_list(){
  dialog --form "Test form" 20 40 10 \
	  "first:" 1 1 Slackware 1 8 10 10 \
	  "second:" 2 1 Slackware 2 8 10 10 \
	  "third:" 3 1 Slackware 3 8 10 10 2> /tmp/dialog.txt 
}

#form_list

case $1 in
	audio_ctl)
  	  pa_control
	;;
	radio_ctl)
  	  rf_control
	;;
	panel_ctl)
  	  brightness_control
	;;
	*)
  	  menu_show
	;;
	help)
	echo "$0 audio_ctl|radio_ctl|panel_ctl"
	;;
esac		
