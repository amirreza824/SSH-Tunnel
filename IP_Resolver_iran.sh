#!/bin/sh

PWD=$(pwd)
TMP_FILE=$(mktemp --suffix=_ROUTE)
chmod +x ${TMP_FILE}

SITES=$(cat ${PWD}/SiteList.txt)

echo $SITES | tr ' ' '\n' | while read line
	do
	host -tA ${line}  | awk '{print "/sbin/ip route add "$4"/32 via 192.168.10.33 dev eth0;"}' >> ${TMP_FILE}
	done

${TMP_FILE}

rm -rf ${TMP_FILE}
