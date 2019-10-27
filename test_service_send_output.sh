#!/bin/sh
# tested in FreeBSD server
# This script is placed in cron file and runs every 5 minutes.
DHCPRUN="/usr/local/etc/rc.d/isc-dhcpd restart"
RECIPIENTS="some-recipient@example.com some-other-recipient@example.com"
SENDMAIL="/usr/bin/mail -s"
#if ps ax | grep -v grep | grep $SERVICE > /dev/null
$DHCPRUN 2> /root/dhcp_output.txt
# once isc-dhcp service is restarted, if there is any fault in config file, service will fail and gives output about faulty lines.
if cat /root/dhcp_output.txt | grep ERROR > /dev/null
then
    echo "dhcp is down" > /dev/null
    SUBJECT="DHCP_ERROR!!"
    echo "DHCP service stopped due to mispelled config file. Correct the lines above pointed with ^ character!" >> /root/dhcp_output.txt
    $SENDMAIL "$SUBJECT" "$RECIPIENT" < /root/dhcp_output.txt
fi
