#! /bin/bash
#Checking if this script is being executed as ROOT. For maintaining proper directory structure, this script must be run from a root user.
if [ $EUID != 0 ]
then
  echo "Please run this script as root so as to see all details! Better run with sudo."
  exit 1
fi
MYUSER=root
MYPASS=osi123
dte=`date`
hstname=`hostname`
ip_add=172.18.0.9
#`ifconfig | grep "inet" | head -2 | sed ' /172.17.0.1/d ' | awk {'print$2'}| cut -f2 -d:`
UP1=`service mysql status|grep 'active (running)' | awk ' { print $3} '`
if [ "$UP1" = '(running)' ]
then
INSTSTAT=("${ERRORS[@]}" "Running")
elif [ "$UP1" != '(running)' ]
then
INSTSTAT=("${ERRORS[@]}" "Not Running")
fi
upt=`mysql -u$MYUSER -p$MYPASS -e "status;" | grep "Uptime" | awk '{ print $2 ;print $3 }'`
sr_version=`mysql -u$MYUSER -p$MYPASS -e "status;" | grep "Server version" | awk '{print $3;print $4;print $5; print $6}'`
load_avg=`cat /proc/loadavg  | awk {'print$1,$2,$3'} | sed 's/ /,/g'`
ram_usage=`free -m | head -2 | tail -1 | awk {'print$3'}`
ram_total=`free -m | head -2 | tail -1 | awk {'print$2'}`
mem_pct=`free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }'`
mnt_pnt=`df -PH | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 "  " $6":" }' | sed 's/:/,/g'`
usr_sta=`mysql -u$MYUSER -p$MYPASS -e "show full processlist;" | sed ' /User/d ' | awk '{ print $2 }' `
db_size=`mysql -u$MYUSER -p$MYPASS -e "SELECT table_schema AS 'DB Name', ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) AS 'DB Size in MB' FROM information_schema.tables GROUP BY table_schema;" | sed ' /DB Name/d '`
usd_conn=`df /dev/sda1 | sed ' /Use%/d ' | awk '{print $5}'`
if [[ $usd_conn < 70% ]]
then
INSTSTA=("${ERRORS[@]}" "healthy")
else
INSTSTA=("${ERRORS[@]}" "unhealthy")
fi


#remove index
sudo rm /var/www/html/index.html

#Creating a directory if it doesn't exist to store reports first, for easy maintenance.
if [ ! -d /var/www/html/ ]
then
  mkdir /var/www/html/
fi
find /var/www/html/ -mtime +1 -exec rm {} \;
html="/var/www/html/index.html"
for i in `ls /home`; do sudo du -sh /home/$i/* | sort -nr | grep G; done > /tmp/dir.txt
#Generating HTML file
echo "<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">" >> $html
echo "<html>" >> $html
echo "<link rel="stylesheet" href="https://unpkg.com/purecss@0.6.2/build/pure-min.css">" >> $html
echo "<body bgcolor="#FBFFC2">" >> $html
echo "<fieldset>" >> $html
echo "<center>" >> $html
echo "<h2><u>MySQL Server Health Report</u></h2>" >> $html
echo "<h3><legend>MySQL Server health Report</legend></h3>" >> $html
echo "<h4><legend>Version 1.0</legend></h4>" >> $html
echo "</center>" >> $html
echo "</fieldset>" >> $html
echo "<br>" >> $html
echo "<center>" >> $html
############################################MySQL Instance Details#######################################################################
echo "<h3><u>MySQL Instance Details:</u> </h3>" >> $html
echo "<table class="pure-table">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th>Hostname</th>" >> $html
echo "<th>IP Address</th>" >> $html
echo "<th>Instance Status</th>" >> $html
echo "<th>Server Version</th>" >> $html
echo "<th>Uptime</th>" >> $html
echo "<th>Date & Time</th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
echo "<td>$hstname</td>" >> $html
echo "<td>$ip_add</td>" >> $html
echo "<td><font color="Green">$INSTSTAT</font></td>" >> $html
echo "<td>$sr_version</td>" >> $html
echo "<td>$upt</td>" >> $html
echo "<td>$dte</td>" >> $html
echo "</tr>" >> $html
echo "</tbody>" >> $html
echo "</table>" >> $html
############################################MySQL Connection Details#######################################################################
echo "<h3><u>MySQL Connection Details:</u> </h3>" >> $html
echo "<table class="pure-table">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th>User Connections</th>" >> $html
echo "<th>Data Base Size</th>" >> $html
#echo "<th>Disk Space</th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
echo "<td>$usr_sta</td>" >> $html
echo "<td>$db_size</td>" >> $html
#echo "<td></td>" >> $html
echo "</tr>" >> $html
echo "</tbody>" >> $html
echo "</table>" >> $html
########################################### Resource Status #######################################################################
echo "<h3><u>Resource Utilization :</u> </h3>" >> $html
echo "<br>" >> $html
echo "<table class="pure-table">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th>Load Average</th>" >> $html
echo "<th>Used RAM(in MB)</th>" >> $html
echo "<th>Total RAM(in MB)</th>" >> $html
echo "<th>Memory Utilization %</th>" >> $html
echo "<th>Disk Space</th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
echo "<td><center>$load_avg</center></td>" >> $html
echo "<td><center>$ram_usage</center></td>" >> $html
echo "<td><center>$ram_total</center></td>" >> $html
echo "<td><center>$mem_pct</center></td>" >> $html
echo "<td><center>$INSTSTA</center></td>" >> $html
echo "</tr>" >> $html
echo "</tbody>" >> $html
echo "</table>" >> $html
########################################### Disk Utilization #######################################################################
echo "<h3><u>Disk Utilization:</u> </h3>" >> $html
echo "<table class="pure-table">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th><center>Mount Point Usage</center></th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
echo "<td>$mnt_pnt</td>" >> $html
echo "</tr>" >> $html
echo "</tbody>" >> $html
echo "</table>" >> $html
echo "<br />" >> $html
echo "</table>" >> $html
echo "</body>" >> $html
echo "</html>" >> $html
echo "Report has been generated with file-name = $html. "
service nginx restart

