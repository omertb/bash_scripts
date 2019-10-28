#!/bin/bash
# this script is built with the purpose of making a roundabout to a bug in Cisco WLC; that is,
# the AP loses its vlan enable configuration if there is a power outage.
cd /home/monitor/ap_flex/
DATE=`date +%Y%m%d%H%M`
SENDMAIL="/usr/bin/mail"
SENDER="From: WLC Check Script"
RECIPIENTS="some-recipient@example.com,some-other-recipient@example.com"
SUBJECT="WAP V-Tag Correction Status"

while read line ;do
#
    CTRLIP=$line
    # there is an expect script file in the same directory ssh to controller and getting the "show ap uptime".
    ./sh_ap_uptime.exp $CTRLIP > sh_ap_uptime_$CTRLIP.txt
    grep "days," sh_ap_uptime_$CTRLIP.txt > ap_status_$CTRLIP.txt
    #
    # Get the fourth column and trim it.
    grep "Number of APs" sh_ap_uptime_$CTRLIP.txt | awk -F" " '{print $4}' | tr -d '\b\r' > AP_Number_$CTRLIP.txt
    #
    # Get the AP names joined to controller and write to a file line by line.
    cat ap_status_$CTRLIP.txt | awk -F" " '{print $1}' > AP_LIST_$CTRLIP.txt
#
#    cut -d " " -f 1 ap_status_$CTRLIP.txt > AP_LIST_$CTRLIP.txt
    # the expect file running "show config ap" command
    ./sh_config_ap.exp $CTRLIP > ap_config_all_$CTRLIP.txt
    # get both lines containing "Cisco AP Name" and "FlexcConnect Vlan mode"
    cat ap_config_all_$CTRLIP.txt | grep "Cisco AP Name\|FlexConnect Vlan mode" | tr -d '\b\r' > Flex_Status_$CTRLIP.txt
    #
    # get the AP names before each lines containing word "Disabled" and write those APs to a file
    cat Flex_Status_$CTRLIP.txt | grep -B 1 "Disabled" | grep -v "Disabled\|\-\-" | awk -F" " '{print $4}' > VLAN_DISABLED_$CTRLIP.txt
    # if file size is not zero, then begin the config to enable vlan disabled APs
    if [ -s VLAN_DISABLED_"$CTRLIP".txt ]
    then
        cp VLAN_DISABLED_$CTRLIP.txt DISABLED_VLAN_HISTORY/VLAN_DISABLED_"$CTRLIP"_"$DATE".txt
        # the expect file including vlan enabling configuration
        ./vlan_cure.exp $CTRLIP
        $SENDMAIL -a "$SENDER" -s "$SUBJECT" "$RECIPIENTS" < VLAN_DISABLED_$CTRLIP.txt
    fi
done < CTRL_IP_LIST  # Wireless controllers IP list file.
