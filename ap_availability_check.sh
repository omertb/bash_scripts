#!/bin/bash
# this script is built to get alarms on missing or returning APs
# due to power loss or intended breakoffs.
cd /home/monitor/ap_availability/
DATE=`date +%Y%m%d%H%M`
SENDMAIL="/usr/bin/mail"
SENDER="From: ap_monitor"
RECIPIENT="recipient1@example.com,recipient2@example.com"
SUBJECT="AP Availability Status"
while read line ;do
#
    CTRLIP=$line
    ./sh_ap_summary.exp $CTRLIP > sh_ap_summary_$CTRLIP.txt
    cp sh_ap_summary_$CTRLIP.txt history_ap_summary/summary_"$CTRLIP"_"$DATE".txt
    grep " 0 " sh_ap_summary_$CTRLIP.txt | awk -F" " '{print $1}' | tr -d '\b\r' > zc_aps_$CTRLIP.txt
    cp zc_aps_$CTRLIP.txt history/zc_aps_"$CTRLIP"_"$DATE".txt

done < CTRL_IP_LIST
cd /home/monitor/ap_availability/history_ap_summary
# sort all APs in both controllers and save themt to a file
cat summary*"$DATE".txt | grep AIR | cut -d " " -f1 | sort > all_aps"$DATE".txt
diff `cat previous_stuation.txt` all_aps"$DATE".txt > diff_"$DATE".txt
cat diff_"$DATE".txt | grep ">" > email_body.txt
if [ $? -eq 0 ]; then
    echo "named AP(s) have just become available " >> email_body.txt
fi
cat diff_"$DATE".txt | grep "<" >> email_body.txt
if [ $? -eq 0 ]; then
    echo "named APs are NOT available" >> email_body.txt
fi
cat email_body.txt | grep "<\|>"
if [ $? -eq 0 ]; then
    $SENDMAIL -a "$SENDER" -s "$SUBJECT" "$RECIPIENT" < email_body.txt
fi
echo all_aps"$DATE".txt > previous_stuation.txt