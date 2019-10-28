#!/bin/bash
# script for freeradius service stopping unexpectedly, that doesn't happen unreasonably, but I had needed that.
freeradpid=""
RAD_RESPONSE=""
freeradpid=`ps -C freeradius -o pid=`
if [ "$freeradpid" = "" ]
then
    echo "..."
    echo "not running, starting now!"
    /etc/init.d/freeradius start
else
    echo "..."
    echo "runnning with pid number $freeradpid."
    RAD_RESPONSE=`timeout 1 radtest RADIUS_TEST_ACCOUNT TEST_ACCOUNT_PASSWORD localhost 0 CLIENT_PASSPHRASE | grep Access-Accept`
    if [ "$RAD_RESPONSE" = "" ]
    then
        echo "..."
        echo "but does not respond to authentication requests, restarting now!"
        /etc/init.d/freeradius restart
    else
        echo "..."
        echo $RAD_RESPONSE
        echo "..."
        echo "Freeradius responds to authentication requests."
    fi
RAD_RESPONSE=""
freeradpid=""
fi