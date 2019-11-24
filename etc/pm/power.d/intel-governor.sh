
function laptop_mode_battery(){
  /usr/local/sbin/intel-performance-state.sh true
}

function laptop_mode_ac(){
  /usr/local/sbin/intel-performance-state.sh false
}

case $1 in
    true) laptop_mode_battery ;;
    false) laptop_mode_ac ;;
    *) exit $NA ;;
esac

exit 0
