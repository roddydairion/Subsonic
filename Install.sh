#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/Common.sh"

main()
{
	detect_os
	export PATH=$PATH:/usr/local/bin
	filename=$(curl -sIkL https://sourceforge.net/projects/subsonic/files/latest/download?source=files | sed -r '/filename=/!d;s/.*filename=(.*)$/\1/')
	formatfile=$(echo "${filename}" | sed 's/\"//g')

	IFS='-' read -ra SEP <<< "$formatfile"

	echo "Removing old Subsonic installation"
	if [ $os == "centos" ]
	then
		extension="rpm"
		sudo yum remove -y subsonic
		sudo yum install -y java-1.7.0-openjdk
	elif [ $os == "ubuntu" ]
	then
		extension="deb"
		sudo apt-get remove -y subsonic
		sudo apt-get install -y openjdk-7-jdk
	else
		$(wget -O --content-disposition https://sourceforge.net/projects/subsonic/files/latest/download?source=files)
		tar -xvzf "${filename}"
		echo -e "\nDownloaded Standalone version. Go to http://www.subsonic.org/pages/installation.jsp#standalone, to configure Subsonic."
		exit
	fi
	
	subsonicURL="http://subsonic.org/download/"
	subsonicFILE="subsonic-6.0.beta2.rpm"

	echo -n "Enter subsonic file name to download (Leave blank to download latest version): "
	read text
	if [ -z "$text"]
	then
		$(wget --content-disposition https://sourceforge.net/projects/subsonic/files/subsonic/${SEP[1]}/${SEP[0]}-${SEP[1]}.${extension}/download)
		subsonicFILE="${SEP[0]}-${SEP[1]}.${extension}"
	else
		wget "${subsonicURL}${subFile}"
	fi

	if [ $os == "centos" ]
	then
		sudo yum install -y --nogpgcheck "${subsonicFILE}"
	elif [ $os == "ubuntu" ]
	then
		sudo dpkg -i "${subsonicFILE}"
	else
		echo "No package to install!"
		exit
	fi
	
	rm -rf "${subsonicFILE}"
	./RunConfig.sh
}

main