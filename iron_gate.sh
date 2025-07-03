#!/bin/bash
echo
echo "IronGate is a rapid-response network lockdown tool. Built for SOC operators and field analysts, it instantly drops all interfaces, kills outbound/inbound traffic, disables DNS, and air-gaps the system in seconds. Use it to isolate compromised hosts, contain active threats, or sever all network activity — fast, quiet, and on your terms."
echo
echo "Press CTRL + C to exit!"
echo
#sleep 15s

#Extends the timeout for sudo.
echo
read -p "Enable sudo -v to allow commands to run w/out re-entering your password for 5 minutes? (y/n): " time_extension
if [[ "$time_extension" == "y" || "$time_extension" == "Y" ]];
then
	sudo -v
	echo
	echo "You will not have to enter your password for 5 minutes."
fi
#sleep 5s

# Enables logging of all options the user selects in CSV format, to a hidden file called .irongate_log, in the /home dir.
LOGFILE="$HOME/.irongate_log.csv"
echo "Check,Command,Result" > "$LOGFILE"

# Enables hash SHA256sum hash for the script and the hidden .irongate_log file for security.
#SCRIPT_PATH="$(readlink -f "$0")"
#EXPECTED_HASH="c72e977e1e52ffcb179571ddb275b50f0c5bce5f32fc3fc61bbc343051f77c57"
#CURRENT_HASH="$(sha256sum "$SCRIPT_PATH" | awk '{print $1}')"

#if [[ "$CURRENT_HASH" != "$EXPECTED_HASH" ]]; then
  #echo "[SECURITY ALERT] IronGate script integrity check failed!"
  #echo "$(date +'%Y-%m-%d %H:%M:%S'),Integrity Check,Script tampered,FAIL" >> "$LOGFILE"
  #exit 1
#fi


echo
echo "INTERFACES: "
echo
sudo tcpdump -D
echo

while true; do
# User menu w/options.
	echo
	echo "Select an option: "
	echo
	echo "1) Level 1 - Turn off interfaces."
	echo "2) Level 2 - Remove DNS & Routing"
	echo "3) Level 3 - Flush firewall & block all."
	echo "4) Level 4 - Kill NIC."
	echo "5) Level 5 - Blackout"
	echo "6) Restore interfaces."
	echo "7) Restore DNS."
	echo "8) Restore firewall."
	echo "9) Restore NIC."
	echo "10) Restore system."

# Prompt user for choice.
	echo
	read -p "Make a selection: " choice
	echo

# Commands
case $choice in
	1) 
{
sudo ip link set wlan0 down && sudo ip link set eth0 down && sudo rfkill block wifi && sudo rfkill block all && sudo chattr -i /etc/resolv.conf 2>/dev/null && sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
# LEVEL 1 – Shutdown of interfaces & RF.
echo
echo "$(date +'%Y-%m-%d %H:%M:%S'),Interface Down,wlan0,$(ip link show wlan0 | grep -q 'state DOWN' && echo 'DOWN' || echo 'UP')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Interface Down,eth0,$(ip link show eth0 | grep -q 'state DOWN' && echo 'DOWN' || echo 'UP')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),RFKill Wifi,wifi,$(rfkill list wifi | grep -q 'Soft blocked: yes' && echo 'Blocked' || echo 'Not Blocked')" >> "$LOGFILE"
echo
};;
	2) 
{
sudo systemctl stop systemd-resolved && sudo systemctl disable systemd-resolved && sudo rm -f /etc/resolv.conf && sudo ip route flush all
# LEVEL 2 – Removal of DNS & Routing
echo
echo "$(date +'%Y-%m-%d %H:%M:%S'),DNS Service,systemd-resolved,$(systemctl is-enabled systemd-resolved 2>/dev/null)" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),DNS Service Active,systemd-resolved,$(systemctl is-active systemd-resolved 2>/dev/null)" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Routing Table,default route,$(ip route show | grep -q '^default' && echo 'Present' || echo 'Cleared')" >> "$LOGFILE"
echo
};;
	3) 
{
sudo bash -c '
iptables -F
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
'2>/dev/null
# LEVEL 3 – Flushing of firewall & blocking all.
echo
echo "$(date +'%Y-%m-%d %H:%M:%S'),Firewall Policy,INPUT,$(iptables -L INPUT -n | grep -q 'policy DROP' && echo 'DROP' || echo 'ACCEPT')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Firewall Policy,OUTPUT,$(iptables -L OUTPUT -n | grep -q 'policy DROP' && echo 'DROP' || echo 'ACCEPT')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Firewall Policy,FORWARD,$(iptables -L FORWARD -n | grep -q 'policy DROP' && echo 'DROP' || echo 'ACCEPT')" >> "$LOGFILE"
echo
};;
	4) 
{
echo 1 | sudo tee /sys/class/net/wlan0/device/remove && echo 1 | sudo tee /sys/class/net/eth0/device/remove
# LEVEL 4 – Termination of NIC.
echo
echo "$(date +'%Y-%m-%d %H:%M:%S'),NIC Removal,wlan0,$(ls /sys/class/net | grep -q 'wlan0' && echo 'Present' || echo 'Removed')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),NIC Removal,eth0,$(ls /sys/class/net | grep -q 'eth0' && echo 'Present' || echo 'Removed')" >> "$LOGFILE"
echo
};;
	5) 
{
# BLACKOUT PROTOCOL
sudo ip link set wlan0 down
sudo ip link set eth0 down
sudo rfkill block wifi
sudo rfkill block all
sudo chattr -i /etc/resolv.conf 2>/dev/null
sudo rm -f /etc/resolv.conf
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo ip route flush all
sudo bash -c '
iptables -F
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
'
echo 1 | sudo tee /sys/class/net/wlan0/device/remove
echo 1 | sudo tee /sys/class/net/eth0/device/remove
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
sudo modprobe -r iwlwifi 2>/dev/null
sudo modprobe -r e1000e 2>/dev/null
# LEVEL 5 – Blackout
echo
echo "$(date +'%Y-%m-%d %H:%M:%S'),NetworkManager,Enabled,$(systemctl is-enabled NetworkManager 2>/dev/null)" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),NetworkManager,Active,$(systemctl is-active NetworkManager 2>/dev/null)" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Driver Loaded,iwlwifi,$(lsmod | grep -q 'iwlwifi' && echo 'Loaded' || echo 'Unloaded')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Driver Loaded,e1000e,$(lsmod | grep -q 'e1000e' && echo 'Loaded' || echo 'Unloaded')" >> "$LOGFILE"
echo
};;
	6) 
{
sudo systemctl enable systemd-resolved && sudo systemctl start systemd-resolved && sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
# LEVEL 6 – Restoration of DNS.
echo
echo "$(date +'%Y-%m-%d %H:%M:%S'),DNS File,Exists,$([ -L /etc/resolv.conf ] && echo 'Symlink Present' || echo 'Missing')" >> "$LOGFILE"
echo
};;
	7) 
{
sudo dhclient wlan0 && sudo dhclient eth0
# LEVEL 7 – DHCP/IP Address
echo
echo "$(date +'%Y-%m-%d %H:%M:%S'),IP Assigned,wlan0,$(ip addr show wlan0 2>/dev/null | grep -q 'inet ' && echo 'Yes' || echo 'No')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),IP Assigned,eth0,$(ip addr show eth0 2>/dev/null | grep -q 'inet ' && echo 'Yes' || echo 'No')" >> "$LOGFILE"
echo
};;
	8) 
{
sudo bash -c '
iptables -F
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
'2>/dev/null
# LEVEL 8 – Firewall Rule Restoration
echo
echo "$(date +'%Y-%m-%d %H:%M:%S'),Firewall Policy,INPUT,$(iptables -L INPUT -n | grep -q 'policy ACCEPT' && echo 'ACCEPT' || echo 'DROP')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Firewall Policy,OUTPUT,$(iptables -L OUTPUT -n | grep -q 'policy ACCEPT' && echo 'ACCEPT' || echo 'DROP')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Firewall Policy,FORWARD,$(iptables -L FORWARD -n | grep -q 'policy ACCEPT' && echo 'ACCEPT' || echo 'DROP')" >> "$LOGFILE"
echo
};;
	9)
{
sudo modprobe iwlwifi && sudo modprobe e1000e && echo 1 | sudo tee /sys/bus/pci/rescan > /dev/null && sudo systemctl enable NetworkManager --now && sudo systemctl start NetworkManager && sudo nmcli connection show && echo && read -p "What is the SSID of the duplicate connection to delete? " connection && # For example, if there's "Null110" and "Null110-1":
sudo nmcli connection delete "$connection"
# RESTORE – Reinsert NIC drivers and restart NetworkManager.
echo
echo "$(date +'%Y-%m-%d %H:%M:%S'),NIC Restore,iwlwifi,$(lsmod | grep -q 'iwlwifi' && echo 'Loaded' || echo 'Unloaded')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),NIC Restore,e1000e,$(lsmod | grep -q 'e1000e' && echo 'Loaded' || echo 'Unloaded')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),NIC Restore,Interfaces,$(ip link show | grep -E 'wlan0|eth0' > /dev/null && echo 'Present' || echo 'Missing')" >> "$LOGFILE"
echo
};;
	10) 
{
# RESTORE PROTOCOL
sudo modprobe iwlwifi
sudo modprobe e1000e
echo 1 | sudo tee /sys/bus/pci/rescan > /dev/null
sudo systemctl enable NetworkManager --now
sudo systemctl start NetworkManager
sudo systemctl enable systemd-resolved --now
sudo systemctl start systemd-resolved
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo bash -c '
iptables -F
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
'
sudo dhclient wlan0
sudo dhclient eth0

# AUTO DELETE DUPLICATE SSIDs
main_ssid=$(nmcli -t -f NAME connection show --active | head -n 1 | sed 's/-[0-9]*$//; s/ [0-9]*$//')
if [[ -n "$main_ssid" ]]; then
    nmcli -t -f NAME connection show | grep -E "^$main_ssid[- ]?[0-9]+$" | while read dup; do
        sudo nmcli connection delete "$dup"
    done
fi
# LEVEL 10 – Restoration of system.
echo
echo "$(date +'%Y-%m-%d %H:%M:%S'),Restore,iwlwifi,$(lsmod | grep -q 'iwlwifi' && echo 'Loaded' || echo 'Unloaded')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Restore,e1000e,$(lsmod | grep -q 'e1000e' && echo 'Loaded' || echo 'Unloaded')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Restore,NetworkManager Enabled,$(systemctl is-enabled NetworkManager 2>/dev/null)" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Restore,NetworkManager Active,$(systemctl is-active NetworkManager 2>/dev/null)" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Restore,systemd-resolved Enabled,$(systemctl is-enabled systemd-resolved 2>/dev/null)" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Restore,systemd-resolved Active,$(systemctl is-active systemd-resolved 2>/dev/null)" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Restore,DNS Symlink,$([ -L /etc/resolv.conf ] && echo 'Symlink Present' || echo 'Missing')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Restore,Firewall INPUT Policy,$(iptables -L INPUT -n | grep -q 'policy ACCEPT' && echo 'ACCEPT' || echo 'DROP')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Restore,Firewall OUTPUT Policy,$(iptables -L OUTPUT -n | grep -q 'policy ACCEPT' && echo 'ACCEPT' || echo 'DROP')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Restore,Firewall FORWARD Policy,$(iptables -L FORWARD -n | grep -q 'policy ACCEPT' && echo 'ACCEPT' || echo 'DROP')" >> "$LOGFILE"
echo "$(date +'%Y-%m-%d %H:%M:%S'),Restore,Interfaces,$(ip link show | grep -E 'wlan0|eth0' > /dev/null && echo 'Present' || echo 'Missing')" >> "$LOGFILE"
echo
};;
	esac
done