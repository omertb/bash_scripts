#!/bin/sh
# this script signs logs with timestamp and compresses them in each directory as an item in LIST
day=`date -v -1d +%d`
month=`date -v -1d +%m`
year=`date -v -1d +%Y`
previousday=`date -v -1d +%Y%m%d`
#
#
maindir="/data/logs/syslog/$year/$month/$day"
#
#synchronize time
#
ntpdate 192.168.100.2 > $maindir/result.txt
#

# directory names which includes logs to be signed
LIST="dhcp-server
radius-server
web-01
web-02
bb-firewall
."

for log in $LIST
do

 if test -e $maindir/$log
  then cd $maindir/$log
  tar -zvcf $log_$previousday.tar.gz *.log && find *.log -delete
  /usr/local/ssl/bin/openssl ts -query -data $log_$previousday.tar.gz -no_nonce -out $log_$previousday.tar.gz.tsq
  /usr/local/ssl/bin/openssl ts -reply -queryfile $log_$previousday.tar.gz.tsq -out $log_$previousday.tar.gz.tsr -token_out -config /usr/local/ssl/openssl.cnf -passin pass:1q2w3e4r
  pwd >> $maindir/result.txt
  ls -l >> $maindir/result.txt
  /usr/local/ssl/bin/openssl ts -verify -data $log_$previousday.tar.gz -in $log_$previousday.tar.gz.tsr -token_in -CAfile /CA/cacert.pem -untrusted /CA/tsacert.pem >> $maindir/result.txt
 fi
done

#
# email results to the staff in charge
#
RECIPIENT="sysadmin@example.com"
SENDMAIL="/usr/bin/mail -s"
SUBJECT="LOG_SIGNER"
$SENDMAIL "$SUBJECT" "$RECIPIENT" < ./result.txt
