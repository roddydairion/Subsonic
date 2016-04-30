#!/bin/bash
source Common.sh
export PATH=$PATH:/usr/local/bin

service subsonic stop
useradd --system syssubsonic
gpasswd --add syssubsonic audio

if [ $os == "centos" ]
then
	fileLoc="/etc/sysconfig/subsonic"	
elif [ $os == "ubuntu" ]
then
	fileLoc="/etc/default/subsonic"
else
	echo "No possible OS found to create configuration!"
	exit
fi

if /bin/grep -q "SUBSONIC_USER=root" "${fileLoc}"
then
	$(/bin/sed -i -e 's/\SUBSONIC_USER=root/SUBSONIC_USER=syssubsonic/g' $fileLoc)
else
	echo "Cannot change user. Open /etc/sysconfig/subsonic to manually change SUBSONIC_USER"
fi

if /bin/grep -q "SUBSONIC_ARGS=\"--max-memory=150\"" "${fileLoc}"
then
	$(/bin/sed -i -e 's/\SUBSONIC_ARGS="--max-memory=150"/SUBSONIC_ARGS="--https-port=8404 --max-memory=150"/g' $fileLoc)
else
	echo "Cannot change port number.  Open /etc/sysconfig/subsonic to manually change SUBSONIC_ARGS=\"--max-memory=150\" to SUBSONIC_ARGS=\"--https-port=8404 --max-memory=150\""
fi

sudo iptables -I INPUT -p tcp --dport 8404 -j ACCEPT
service subsonic start