#!/bin/bash
name="Manojkumar"
s3bucket="upgradmanojkumarg"
timeStamp=$(date '+%d%m%Y-%H%M%S')
fileName="$name-httpd-logs-$timeStamp.tar"

apacheSetup () {
echo "Updating packages..."
apt update -y 
echo " "
apache_status=$(systemctl is-active apache2)
if [ "${apache_status}" != "active" ]
then
	dpkg --get-selections | grep -w deinstall
	if [ $(echo $?) -eq 0 ]
	then
		echo " "
		echo "Apache2 Not installed."
		echo " "
		echo "Installing Apache2..."
		apt install apache2 -y
		systemctl enable apache2
		echo " "
		echo "Starting Apache2..."
		systemctl start apache2
		echo "Apache2 Status : $(systemctl is-active apache2 | tr '[:lower:]' '[:upper:]')"
		echo " "
	else
		echo "Starting Apache2..."
		systemctl start apache2
		echo "Apache2 Status : $(systemctl is-active apache2 | tr '[:lower:]' '[:upper:]')"
		echo " "
	fi
else
	echo "Apache2 Already UP and Running" 
	echo " "
fi
}

logArchive () {
ls /var/log/apache2/*.log
if [ $(echo $?) = 0 ]
then
	echo "Taking backup of Apache log files"
	tar -cvf /tmp/${fileName} /var/log/apache2/*.log
	aws s3 cp /tmp/${fileName} s3://${s3bucket}/${fileName}
	if [ $(echo $?) != 0 ]
	then
		echo "${fileName} copy to S3 bucket $s3bucket : FAILED"
	else
		echo "${fileName} copy to S3 bucket $s3bucket : SUCCESS"
	fi
	echo " "
fi
}

apacheSetup
logArchive
