#!/bin/sh
export PATH=$PATH:/usr/local/bin
echo "Removing old Subsonic installation"
sudo yum remove -y subsonic
sudo yum install -y java-1.7.0-openjdk
subsonicURL="http://subsonic.org/download/"
subsonicFILE="subsonic-6.0.beta2.rpm"

echo -n "Enter subsonic file name to download (Leave blank to download latest version): "
read text
if [ -z "$text"]
then
	$(wget -O ../subsonic.rpm https://sourceforge.net/projects/subsonic/files/latest/download?source=files)
	subsonicFILE="subsonic.rpm"
else
	wget "${subsonicURL}${subFile}"
fi

sudo yum install -y --nogpgcheck "${subsonicFILE}"
rm -rf "${subsonicFILE}"
sudo iptables -I INPUT -p tcp --dport 4040 -j ACCEPT
