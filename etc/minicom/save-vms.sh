print " # Saving VM state\r"
print  "migrate \"exec:gzip -c > /srv/qemu/$VMNAME-statefile.gz\"\r"
send "\r"
send "migrate \"exec:gzip -c > /srv/qemu/$VMNAME-statefile.gz\"\r"
