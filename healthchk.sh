#!/bin/bash

touch /tmp/1form.txt

#Farm#
host=*hosturl* ##Host for health monitor bot (.com .net .edu etc)
logfile=/home/ubuntu/health/logs/$host-tmp.log ##Logfile to save data before cleaning
myemail=myemailaccount@myemailprovider.com ##Email address to send mail notification to 

ip="$(curl icanhazip.com)"
curl_status="$(curl -Is "$host" | head -n 1)"
wget_status_dirty="$(wget --spider --server-response "$host" 2>&1)"
wget_status="$(wget --spider --server-response "$host" 2>&1 | grep '200\ OK' | wc -l)"
rtt="$(ping -c5 "$host" | grep rtt | cut -d"/" -f5)"
rtt_rounded="$(printf '%.*f\n' 0 $rtt)"
mailform=/tmp/1form.txt

echo "Round trip of" $rtt

#Range#
date +%d-%m-%y/%H:%M:%S > $logfile

if [ "$wget_status" -lt 1 ]; then

echo "Website is Down"
echo "Website is down" >> $logfile
echo $wget_status_dirty >> $logfile

else

echo "Website is up"
echo "Website is up" >> $logfile
echo $wget_status_dirty >> $logfile


fi

echo "Website round trip time of" $rtt >> $logfile

curl -Is $host | head -n 1 >> $logfile

ping -c 3 $host >> $logfile


#Email stuffs


if [ "$wget_status" -lt 1 ]; then

echo "To: $myemail" > $mailform
echo "From: $myemail" >> $mailform
echo "Subject: Cimpar.com is DOWN" >> $mailform
echo "Round trip response time of $rtt" >> $mailform
echo "Host $host is non-responsive" >> $mailform
echo "Wget obtained response: $wget_status_dirty" >> $mailform
cat $mailform | ssmtp $myemail

rm $mailform

fi

#Bathtub#
mv $logfile /home/ubuntu/health/logs/$host/$host-$wget_status-$(date -d "today" +"%Y%m%d%H%M").log




exit 0 
