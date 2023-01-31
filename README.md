# voltronic_docker_set_config
Set inverter.conf file at boot based on device vendor ID for voltronic docker by ned-kelly / docker-voltronic-homeassistant

this script is made for https://github.com/ned-kelly/docker-voltronic-homeassistant and fork https://github.com/catalinbordan/docker-voltronic-homeassistant

If you use two usb2serial adapters on your raspberry it sometimes happens that on reboot the two devices are inverted between USB0 and USB1, this script launched at boot checks the links created according to the procedure described below and replaces the inverter.conf file with the correct device.

Before you use this script you must apply this procedure that create a symbolic link to the devices example:
```
pi@solarpi:/opt/ha-inverter-mqtt-agent/config $ ll /dev/*my*
lrwxrwxrwx 1 root root 7 Jan 30 00:07 /dev/myUSBinverter -> ttyUSB1
lrwxrwxrwx 1 root root 7 Jan 30 00:07 /dev/myUSBseplos -> ttyUSB0
```


1. Find the idVendor and idProduct with
``` lsusb -v ```

 assuming the idVendor is 067b and idProduct is 2303 for usb adapter for the inverter;
 assuming the idVendor is 0403 and idProduct is 6001 for usb adapter for the battery or what you want;
 
2. Edit the file:
``` /etc/udev/rules.d/99_usbdevices.rules ```

and insert the line like these:
```
SUBSYSTEM=="tty", ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", SYMLINK+="myUSBinverter"
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", SYMLINK+="myUSBseplos"
```

3. Restart udev and trigger pulling the devices:
```
sudo /etc/init.d/udev reload
sudo udevadm trigger
```

4. After this rechek for example:
``` pi@solarpi:/opt/ha-inverter-mqtt-agent/config $ ls -l /dev/|grep my
lrwxrwxrwx 1 root root           7 Jan 30 00:07 myUSBinverter -> ttyUSB1
lrwxrwxrwx 1 root root           7 Jan 30 00:07 myUSBseplos -> ttyUSB0

``` 

# Install the script

assuming you are skilled with linux env, any damage on you system is at your risk.
assuming your user is "pi"
assuming docker voltronic installation folder is /opt/ha-inverter-mqtt-agent
```
mkdir scripts
cd scripts
git clone https://github.com/byte4geek/voltronic_docker_set_config
chmod 700 set_config_inverter.sh

sudo cp -p /opt/ha-inverter-mqtt-agent/config/inverter.conf /opt/ha-inverter-mqtt-agent/config/inverter_USB0.conf
sudo cp -p /opt/ha-inverter-mqtt-agent/config/inverter.conf /opt/ha-inverter-mqtt-agent/config/inverter_USB1.conf
```
edit the file /opt/ha-inverter-mqtt-agent/config/inverter_USB0.conf and set /dev/ttyUSB0 as the device;
edit the file /opt/ha-inverter-mqtt-agent/config/inverter_USB1.conf and set /dev/ttyUSB1 as the device;

if you use a different folder for you voltronic docker change the path above and change the path iside the script:,
```
LOGNAME=/opt/ha-inverter-mqtt-agent/set_config.log
CONFIG_USB0=/opt/ha-inverter-mqtt-agent/config/inverter_USB0.conf
CONFIG_USB1=/opt/ha-inverter-mqtt-agent/config/inverter_USB1.conf
CONFIG_FILE=/opt/ha-inverter-mqtt-agent/config/inverter.conf
```
```
crontab -e
```
and add at bottom of file the command:
```
nohup sudo /home/pi/scripts/set_config_inverter.sh &
```

enjoy

# Donation
Buy me a coffee

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=VK4CSX9NVQAZU)
