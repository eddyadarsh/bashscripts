#!/bin/bash
# by Adarsh Sharma on 12-10-2012

status=0

BOX=`hostname -f`

critical_emails="app@app.com aa@ad.com" #multiple emails space separated

warning_emails="afsd@sd.com"
#warning_emails="afsd@sdfjk.com"
DownSubject="Replication status - Down"
GoodSubject="Replication status - Good"

GoodMessage="Everything regarding MySQL replication on $SlaveHost is good.\nHave a great day!\n\n"

#Grab the lines for each and use Gawk to get the last part of the string(Yes/No)
SQLresponse=`mysql mysql -e "show slave status \G" |grep -i "Slave_SQL_Running"|gawk '{print $2}'`
IOresponse=`mysql  mysql -e "show slave status \G" |grep -i "Slave_IO_Running"|gawk '{print $2}'`
SlaveLag=`mysql  mysql -e "show slave status \G" |grep -i "Seconds_Behind_Master"|gawk '{print $2}'`


if [ "$SQLresponse" = "No" ]; then
       error="Replication on the slave MySQL server($BOX) has stopped working.\nSlave_SQL_Running: No\n. \nTrying to start it\n"
       status=1
fi

if [ "$IOresponse" = "No" ]; then
      error="Replication on the slave MySQL server($BOX) has stopped working.\nSlave_IO_Running: No\n. \nTrying to start it\n"
      status=1
fi

if [ $SlaveLag -gt 30 ] ; then
        error="[Warning] : Slave is lagging behind by $SlaveLag seconds on $BOX"
        status=2
fi

# If the replication is not working
if [ $status = 1 ]; then
      for address in $critical_emails; do

                echo -e $error | mail -s "Replication is Down : Inform DBOncall ASAP" $address
                echo "Replication down, sent email to $address"
      done
fi
if [ $status = 2 ]; then
      for address in $warning_emails; do

                echo -e $error | mail -s "Slave is lagging on $Box : Please check" $address
                echo "Replication down, sent email to $address"
      done
fi

if [ $status = 0 ]; then
echo "Everything regarding MySQL replication on $SlaveHost is good.\nHave a great day!\n\n"
fi

exit 0

