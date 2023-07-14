#!/bin/sh

# appllication:uhp switch sat
# version:1.0.0 2022-8-16 hyl
# version:1.0.1 2022-8-18 hyl
# version:1.0.2 2022-9-20 jjx
# version:1.0.3 2023-7-12 jjx
##############################

update_version="1.0.3"
dest_packages_path="/etc/config"
src_packages_path="."
app_exec_path="/etc/config/uhp_switch_sat"
tftpd_path="${app_exec_path}/tftpd_dir"


function check_param()
{
	time=$(date '+%Y/%m/%d %H:%M:%S')
	echo "$time [ info ] check_param , param = $1"

	if [ "$1" == "ASIA4-51M" ]
	then
		time=$(date '+%Y/%m/%d %H:%M:%S')
		echo "$time [ info ] param ok = ASIA4-51M (147.5E 51000Ksps 12662MHz H)"
	elif [ "$1" == "ASIA4-31M" ]
	then
		time=$(date '+%Y/%m/%d %H:%M:%S')
		echo "$time [ info ] param ok = ASIA4-31M (147.5E 31000Ksps 11957.5MHz H)"
	elif [ "$1" == "CSAT12-21M" ]
	then
		time=$(date '+%Y/%m/%d %H:%M:%S')
		echo "$time [ info ] param ok = CSAT12-21M (87.5E 21600Ksps 10966MHz V)"
	elif [ "$1" == "CSAT12-51M" ]
	then
		time=$(date '+%Y/%m/%d %H:%M:%S')
		echo "$time [ info ] param ok = CSAT12-51M (87.5E 51000Ksps 11106.5MHz V)"
	elif [ "$1" == "ASIA7-40M" ]
	then
		time=$(date '+%Y/%m/%d %H:%M:%S')
		echo "$time [ info ] param ok = ASIA7-40M (105.5E 40000Ksps 12717MHz V)"
	elif [ "$1" == "CSAT11-6M" ]
	then
		time=$(date '+%Y/%m/%d %H:%M:%S')
		echo "$time [ info ] param ok = CSAT11-6M (98.2E 6600Ksps 11511MHz H)"
	else
		time=$(date '+%Y/%m/%d %H:%M:%S')
		echo "$time [ error ] param error , param = $1"
		echo "$time [ info ] switch to ASIA4-51M (147.5E 51000Ksps 12662MHz H) cmd: sh ./upd_switch.sh ASIA4-51M"
		echo "$time [ info ] switch to ASIA4-31M (147.5E 31000Ksps 11957.5MHz H) cmd: sh ./upd_switch.sh ASIA4-31M"
		echo "$time [ info ] switch to CSAT12-21M (87.5E 21600Ksps 10966MHz V) cmd: sh ./upd_switch.sh CSAT12-21M"
		echo "$time [ info ] switch to CSAT12-51M (87.5E 51000Ksps 11106.5MHz V) cmd: sh ./upd_switch.sh CSAT12-51M"
		echo "$time [ info ] switch to ASIA7-40M (105.5E 40000Ksps 12717MHz V) cmd: sh ./upd_switch.sh ASIA7-40M"
		echo "$time [ info ] switch to CSAT11-6M (98.2E 6600Ksps 11511MHz H) cmd: sh ./upd_switch.sh CSAT11-6M"
		echo "$time [ error ] process will exit ..."
		exit 1
	fi
}

function install_packages()
{
	time=$(date '+%Y/%m/%d %H:%M:%S')
	echo "$time [ info ] to install packages"
	cp -rf ${src_packages_path}/etc/config/* ${dest_packages_path}
	chmod -R 755 ${app_exec_path}
}

function setup_tftpd()
{
	time=$(date '+%Y/%m/%d %H:%M:%S')
	echo "$time [ info ] to setup_tftpd"
	killall atftpd
	sleep 1
	${app_exec_path}/atftpd --daemon --port 69 ${tftpd_path}
}

function modem_load_cfg()
{
	time=$(date '+%Y/%m/%d %H:%M:%S')
	echo "$time [ info ] to modem_load_cfg"

	# set tftp server
	msg=$(curl -iksL 'http://192.168.222.1/cw21?ia=192.168.222.5&db=0&ta=Apply' | grep "200 OK")
	if [ ${#msg} -lt 3 ]
	then
		time=$(date '+%Y/%m/%d %H:%M:%S')
		echo "$time [ error ] set uhp tftp server error , process will exit"
		exit 1
	else
		time=$(date '+%Y/%m/%d %H:%M:%S')
		echo "$time [ info ] set uhp tftp server OK"
	fi

	sleep 3
	# load profile
	msg=$(curl -iksL 'http://192.168.222.1/cw1?da=0&tb=uhp-ditel.cfg&td=Load' | grep "200 OK")
	if [ ${#msg} -lt 3 ]
	then
		time=$(date '+%Y/%m/%d %H:%M:%S')
		echo "$time [ error ] load uhp profile error , process will exit"
		exit 1
	else
		time=$(date '+%Y/%m/%d %H:%M:%S')
		echo "$time [ info ] load uhp profile OK"
	fi
	sleep 6
}

modem_autorun_cfg()
{
	time=$(date '+%Y/%m/%d %H:%M:%S')
	echo "$time [ info ] to modem_autorun_cfg"
	# Info: only enable profile1 profile2 autorun
	# db=1  profile1 enable autorun
	# dc=1  profile2 enable autorun
	msg=$(curl -iksL 'http://192.168.222.1/cA3?db=1&dc=1&dd=1&de=1&df=1&ta=Apply' | grep "200 OK")
	if [ ${#msg} -lt 3 ]
	then
		time=$(date '+%Y/%m/%d %H:%M:%S')
		echo "$time [ error ] enable profile1 profile2 autorun error , process will exit"
		exit 1
	else
		time=$(date '+%Y/%m/%d %H:%M:%S')
		echo "$time [ info ] enable profile1 profile2 autorun OK"
	fi
}

function switch_to_sat()
{
	time=$(date '+%Y/%m/%d %H:%M:%S')
	echo "$time [ info ] switch_to_sat , param = $1"
	is_ok=0
	for i in $(seq 1 1 5)
	do
		if [ "$1" == "ASIA4-51M" ]
		then
			time=$(date '+%Y/%m/%d %H:%M:%S')
			echo "$time [ info ] switch to ASIA4-51M (147.5E 51000Ksps 12662MHz H)"
			echo '' > /etc/config/WEB/SatelliteInfo/GetSatelliteInfoOutput
			echo '$GCCMD,GET SAT DATA*FF' > /etc/config/WEB/SatelliteInfo/GetSatelliteInfoInput
			sleep 5
			msg=$(cat /etc/config/WEB/SatelliteInfo/GetSatelliteInfoOutput | grep "147.5,2062.0000,1,51000,")
			[ ${#msg} -ge 20 ] && is_ok=1 && echo "$time [ info ] current SAT is ASIA4-51M, will not switch" && break
			sleep 1
			echo '' > /etc/config/WEB/SatelliteInfo/SwitchSatelliteOutput
			echo '$GCCMD,AUTO SEARCH WEB,147.5,2062,1,51000,20000,0,0,1,0,15000,2,4,10600,1,ASIA4-51M*FF' > /etc/config/WEB/SatelliteInfo/SwitchSatelliteInput
			sleep 5
			msg=$(cat /etc/config/WEB/SatelliteInfo/SwitchSatelliteOutput | grep OK)
			[ ${#msg} -ge 2 ] && is_ok=1 && echo "$time [ info ] switch to ASIA4-51M OK" && break
			[ ${#msg} -lt 2 ] && is_ok=0 && echo "$time [ warning ] switch to ASIA4-51M failed, will retry $i ..."
		elif [ "$1" == "ASIA4-31M" ]
		then
			time=$(date '+%Y/%m/%d %H:%M:%S')
			echo "$time [ info ] param ok = ASIA4-31M (147.5E 31000Ksps 11957.5MHz H)"
			echo '' > /etc/config/WEB/SatelliteInfo/GetSatelliteInfoOutput
			echo '$GCCMD,GET SAT DATA*FF' > /etc/config/WEB/SatelliteInfo/GetSatelliteInfoInput
			sleep 5
			msg=$(cat /etc/config/WEB/SatelliteInfo/GetSatelliteInfoOutput | grep "147.5,1357.5000,1,31000,")
			[ ${#msg} -ge 20 ] && is_ok=1 && echo "$time [ info ] current SAT is ASIA4-31M, will not switch" && break
			sleep 1
			echo '' > /etc/config/WEB/SatelliteInfo/SwitchSatelliteOutput
			echo '$GCCMD,AUTO SEARCH WEB,147.5,1357.5,1,31000,20000,0,0,1,0,15000,2,4,10600,1,ASIA4-31M*FF' > /etc/config/WEB/SatelliteInfo/SwitchSatelliteInput
			sleep 5
			msg=$(cat /etc/config/WEB/SatelliteInfo/SwitchSatelliteOutput | grep OK)
			[ ${#msg} -ge 2 ] && is_ok=1 && echo "$time [ info ] switch to ASIA4-31M OK" && break
			[ ${#msg} -lt 2 ] && is_ok=0 && echo "$time [ warning ] switch to ASIA4-31M failed, will retry $i ..."
		elif [ "$1" == "CSAT12-21M" ]
		then
			time=$(date '+%Y/%m/%d %H:%M:%S')
			echo "$time [ info ] param ok = CSAT12-21M (87.5E 21600Ksps 10966MHz V)"
			echo '' > /etc/config/WEB/SatelliteInfo/GetSatelliteInfoOutput
			echo '$GCCMD,GET SAT DATA*FF' > /etc/config/WEB/SatelliteInfo/GetSatelliteInfoInput
			sleep 5
			msg=$(cat /etc/config/WEB/SatelliteInfo/GetSatelliteInfoOutput | grep "87.5,1216.0000,0,21600,")
			[ ${#msg} -ge 20 ] && is_ok=1 && echo "$time [ info ] current SAT is CSAT12-21M, will not switch" && break
			sleep 1
			echo '' > /etc/config/WEB/SatelliteInfo/SwitchSatelliteOutput
			echo '$GCCMD,AUTO SEARCH WEB,87.5,1216,0,21600,20000,0,0,0,0,15000,2,3,9750,1,CSAT12-21M*FF' > /etc/config/WEB/SatelliteInfo/SwitchSatelliteInput
			sleep 5
			msg=$(cat /etc/config/WEB/SatelliteInfo/SwitchSatelliteOutput | grep OK)
			[ ${#msg} -ge 2 ] && is_ok=1 && echo "$time [ info ] switch to CSAT12-21M OK" && break
			[ ${#msg} -lt 2 ] && is_ok=0 && echo "$time [ warning ] switch to CSAT12-21M failed, will retry $i ..."
		elif [ "$1" == "CSAT12-51M" ]
		then
			time=$(date '+%Y/%m/%d %H:%M:%S')
			echo "$time [ info ] param ok = CSAT12-51M (87.5E 51000Ksps 11106.5MHz V)"
			echo '' > /etc/config/WEB/SatelliteInfo/GetSatelliteInfoOutput
			echo '$GCCMD,GET SAT DATA*FF' > /etc/config/WEB/SatelliteInfo/GetSatelliteInfoInput
			sleep 5
			msg=$(cat /etc/config/WEB/SatelliteInfo/GetSatelliteInfoOutput | grep "87.5,1356.5000,0,51000,")
			[ ${#msg} -ge 20 ] && is_ok=1 && echo "$time [ info ] current SAT is CSAT12-51M, will not switch" && break
			sleep 1
			echo '' > /etc/config/WEB/SatelliteInfo/SwitchSatelliteOutput
			echo '$GCCMD,AUTO SEARCH WEB,87.5,1356.5,0,51000,20000,0,0,0,0,15000,2,2,9750,1,CSAT12-51*FF' > /etc/config/WEB/SatelliteInfo/SwitchSatelliteInput
			sleep 5
			msg=$(cat /etc/config/WEB/SatelliteInfo/SwitchSatelliteOutput | grep OK)
			[ ${#msg} -ge 2 ] && is_ok=1 && echo "$time [ info ] switch to CSAT12-51M OK" && break
			[ ${#msg} -lt 2 ] && is_ok=0 && echo "$time [ warning ] switch to CSAT12-51M failed, will retry $i ..."
		elif [ "$1" == "ASIA7-40M" ]
		then
			time=$(date '+%Y/%m/%d %H:%M:%S')
			echo "$time [ info ] param ok = ASIA7-40M (105.5E 40000Ksps 12717MHz V)"
			echo '' > /etc/config/WEB/SatelliteInfo/GetSatelliteInfoOutput
			echo '$GCCMD,GET SAT DATA*FF' > /etc/config/WEB/SatelliteInfo/GetSatelliteInfoInput
			sleep 5
			msg=$(cat /etc/config/WEB/SatelliteInfo/GetSatelliteInfoOutput | grep "105.5,2117.0000,0,40000,")
			[ ${#msg} -ge 20 ] && is_ok=1 && echo "$time [ info ] current SAT is ASIA7-40M, will not switch" && break
			sleep 1
			echo '' > /etc/config/WEB/SatelliteInfo/SwitchSatelliteOutput
			echo '$GCCMD,AUTO SEARCH WEB,105.5,2117,0,40000,20000,0,0,1,0,15000,2,5,10600,1,ASIA7-40M*FF' > /etc/config/WEB/SatelliteInfo/SwitchSatelliteInput
			sleep 5
			msg=$(cat /etc/config/WEB/SatelliteInfo/SwitchSatelliteOutput | grep OK)
			[ ${#msg} -ge 2 ] && is_ok=1 && echo "$time [ info ] switch to ASIA7-40M OK" && break
			[ ${#msg} -lt 2 ] && is_ok=0 && echo "$time [ warning ] switch to ASIA7-40M failed, will retry $i ..."
		elif [ "$1" == "CSAT11-6M" ]
		then
			time=$(date '+%Y/%m/%d %H:%M:%S')
			echo "$time [ info ] param ok = CSAT11-6M (98.2E 6600Ksps 11511MHz H)"
			echo '' > /etc/config/WEB/SatelliteInfo/GetSatelliteInfoOutput
			echo '$GCCMD,GET SAT DATA*FF' > /etc/config/WEB/SatelliteInfo/GetSatelliteInfoInput
			sleep 5
			msg=$(cat /etc/config/WEB/SatelliteInfo/GetSatelliteInfoOutput | grep "98.2,1761.0000,1,6600,")
			[ ${#msg} -ge 20 ] && is_ok=1 && echo "$time [ info ] current SAT is CSAT11-6M, will not switch" && break
			sleep 1
			echo '' > /etc/config/WEB/SatelliteInfo/SwitchSatelliteOutput
			echo '$GCCMD,AUTO SEARCH WEB,98.2,1761,1,6600,20000,0,0,0,0,15000,2,1,9750,1,CSAT11-6M*FF' > /etc/config/WEB/SatelliteInfo/SwitchSatelliteInput
			sleep 5
			msg=$(cat /etc/config/WEB/SatelliteInfo/SwitchSatelliteOutput | grep OK)
			[ ${#msg} -ge 2 ] && is_ok=1 && echo "$time [ info ] switch to CSAT11-6M OK" && break
			[ ${#msg} -lt 2 ] && is_ok=0 && echo "$time [ warning ] switch to CSAT11-6M failed, will retry $i ..."
		else
			time=$(date '+%Y/%m/%d %H:%M:%S')
			is_ok=0
			echo "$time [ error ] param error , param = $1"
		fi
	done
	if [ $is_ok -eq 0 ]
	then
		time=$(date '+%Y/%m/%d %H:%M:%S')
		echo "$time [ error ] switch failed , process will exit ..."
		exit 1
	fi
}

function save_and_reboot()
{
	# modem save config
	curl -iksL 'http://192.168.222.1/z' | grep HTTP
	time=$(date '+%Y/%m/%d %H:%M:%S')
	echo "$time [ info ] modem save ok"
	sleep 5
	# reboot modem system
	time=$(date '+%Y/%m/%d %H:%M:%S')
	echo "$time [ info ] modem system reboot ..."
	curl -iksL 'http://192.168.222.1/cw51?ta=Reboot' | grep HTTP
	# reboot acu system
	time=$(date '+%Y/%m/%d %H:%M:%S')
	echo "$time [ info ] acu system reboot ..."
	reboot
}

function main()
{
	time=$(date '+%Y/%m/%d %H:%M:%S')
	echo "$time [ info ] switch to $1 ..."
	check_param $1
	install_packages
	setup_tftpd
	modem_load_cfg
	modem_autorun_cfg
	switch_to_sat $1
	save_and_reboot
}

##### main
main $1
