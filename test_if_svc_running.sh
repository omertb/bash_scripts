#!/usr/local/bin/bash
# mail and try restart the service if stopped
ps cax | grep nswl | grep -v run_nswl
if [ $? -eq 0 ]; then
    echo "Process is running."
else
    echo "Process is not running."
    date > /root/weblog/stopped.txt
    echo "Trying to restart" >> /root/weblog/stopped.txt
    /usr/local/netscaler/bin/nswl -start -f /usr/local/netscaler/etc/log.conf&
    sleep 2
    ps cax | grep nswl | grep -v run_nswl >> /root/weblog/stopped.txt
    if [ $? -eq 0 ]; then
        echo "Success!" >> /root/weblog/stopped.txt
    else
        echo "FAILED!!" >> /root/weblog/stopped.txt
    fi
    /usr/bin/mail -s "weblogger stopped" "user@example.com" < /root/weblog/stopped.txt
fi

