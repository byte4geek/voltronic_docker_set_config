#!/bin/bash
# Check and set inverter.conf file for ned-kelly docker-voltronic-homeassistant
# https://github.com/ned-kelly/docker-voltronic-homeassistant
# https://github.com/catalinbordan/docker-voltronic-homeassistant
# insert in crontab at boot with "nohup sudo /home/pi/voltronic_docker_set_config/set_config_inverter.sh &"
# ver. 1.1 - 31 Jan 2023

LOGNAME=/opt/ha-inverter-mqtt-agent/set_config.log
MAXSIZE=2000000
CONFIG_USB0=/opt/ha-inverter-mqtt-agent/config/inverter_USB0.conf
CONFIG_USB1=/opt/ha-inverter-mqtt-agent/config/inverter_USB1.conf
CONFIG_FILE=/opt/ha-inverter-mqtt-agent/config/inverter.conf

# Functions

log_rotate()
{
	if [ ! -f "$LOGNAME" ]; then
		touch "$LOGNAME"
	else
		LOGNAME_SIZE=$(ls -l "$LOGNAME" | awk '{print $5}')
		if [ $LOGNAME_SIZE -ge $MAXSIZE ]; then
			echo "$(date) - Log file is "$LOGNAME_SIZE" bytes, perform log rotate" >> $LOGNAME
			mv "$LOGNAME" "$LOGNAME".old
		fi
	fi
}

file_copy()
{
	USB_CONFIGURED=$(cat /opt/ha-inverter-mqtt-agent/config/inverter.conf|grep -v "#"|grep device |awk -F "=" '{print $2}')
	USB=$(ls -l /dev/myUSBinverter  | awk '{print $11}')
	USB=$(echo "/dev/"$USB)
	
	if [ $USB = $USB_CONFIGURED ]; then
		echo "$(date) - Device is "$USB", config file is "$USB_CONFIGURED". Config file already configured" >> $LOGNAME
		sleep 600
		elif [ $USB = "/dev/ttyUSB0" ]; then
		cp $CONFIG_USB0 $CONFIG_FILE
		echo "$(date) ->>>>> Device is "$USB", config file is "$USB_CONFIGURED". Copy USB0 config file" >> $LOGNAME
		elif [ $USB = "/dev/ttyUSB1" ]; then
		cp $CONFIG_USB1 $CONFIG_FILE
		echo "$(date) ->>>>> Device is "$USB", config file is "$USB_CONFIGURED". Copy USB1 config file" >> $LOGNAME
	fi
}

# Main

for (( ; ; ))
do
	if [ ! -f "$CONFIG_USB0" ]; then
		echo "$(date) - USB0 config file missing or ureadeable" >> $LOGNAME
		sleep 60
	elif [ ! -f "$CONFIG_USB1" ]; then
		echo "$(date) - USB1 config file missing or ureadeable" >> $LOGNAME
		sleep 60
	elif [ ! -f "$CONFIG_FILE" ]; then
		echo "$(date) - inverter.conf file missing or ureadeable" >> $LOGNAME
		sleep 60
	else
		file_copy
	fi
	
	log_rotate
done
