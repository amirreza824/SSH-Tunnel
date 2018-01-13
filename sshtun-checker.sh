#! /bin/bash

ps aux | grep -i 104.236.118.201 | grep -v grep

if [ `echo $?` != 0 ]
	then
		/bin/bash /home/MYsync/scripts/sshtun.sh  1 > /dev/null
		echo "Tunnel not Running - It's Run at $(date  +%Y-%m-%d-%T) " >> /var/log/amirreza/ssh-tun-checker.log
	else
		echo "Tunnel is Running - everything is GOOD :D - $(date  +%Y-%m-%d-%T) " >> /var/log/amirreza/ssh-tun-checker.log

fi

exit 0
