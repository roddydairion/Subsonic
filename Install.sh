#!/bin/bash
detect_os ()
{
  if [[ ( -z "${os}" ) && ( -z "${dist}" ) ]]; then
    if [ -e /etc/os-release ]; then
      . /etc/os-release
      dist=`echo ${VERSION_ID} | awk -F '.' '{ print $1 }'`
      os=${ID}

    elif [ `which lsb_release 2>/dev/null` ]; then
      # get major version (e.g. '5' or '6')
      dist=`lsb_release -r | cut -f2 | awk -F '.' '{ print $1 }'`

      # get os (e.g. 'centos', 'redhatenterpriseserver', etc)
      os=`lsb_release -i | cut -f2 | awk '{ print tolower($1) }'`

    elif [ -e /etc/oracle-release ]; then
      dist=`cut -f5 --delimiter=' ' /etc/oracle-release | awk -F '.' '{ print $1 }'`
      os='ol'

    elif [ -e /etc/fedora-release ]; then
      dist=`cut -f3 --delimiter=' ' /etc/fedora-release`
      os='fedora'

    elif [ -e /etc/redhat-release ]; then
      os_hint=`cat /etc/redhat-release  | awk '{ print tolower($1) }'`
      if [ "${os_hint}" = "centos" ]; then
        dist=`cat /etc/redhat-release | awk '{ print $3 }' | awk -F '.' '{ print $1 }'`
        os='centos'
	#echo "This is centos"
      elif [ "${os_hint}" = "scientific" ]; then
        dist=`cat /etc/redhat-release | awk '{ print $4 }' | awk -F '.' '{ print $1 }'`
        os='scientific'
      else
        dist=`cat /etc/redhat-release  | awk '{ print tolower($7) }' | cut -f1 --delimiter='.'`
        os='redhatenterpriseserver'
      fi

    else
      aws=`grep -q Amazon /etc/issue`
      if [ "$?" = "0" ]; then
        dist='6'
        os='aws'
      else
        unknown_os
      fi
    fi

  fi

  if [[ ( -z "${os}" ) || ( -z "${dist}" ) || ( "${os}" = "opensuse" ) ]]; then
    unknown_os
  fi

  # remove whitespace from OS and dist name
  os="${os// /}"
  dist="${dist// /}"

  echo "Detected operating system as ${os}/${dist}."
  #rpm -Uvh 
}

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
	elif [ $os == "ubuntu"]
	then
		extension="deb"
		sudo apt-get remove -y subsonic
		sudo apt-get install -y java-1.7.0-openjdk
	else
		echo "No extension found!"
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
	elif [ $os == "ubuntu"]
	then
		sudo dpkg -i "${subsonicFILE}"
	else
		echo "No package to install!"
	fi
	
	rm -rf "${subsonicFILE}"
	sudo iptables -I INPUT -p tcp --dport 4040 -j ACCEPT
}

main