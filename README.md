# debian-setup

Do the following with the root.

```bash
apt-get install sudo vim tmux
```

## sudoers setup

```bash
visudo
```

Add this

```
hagi	ALL=(ALL:ALL)	ALL
```

---

Do the following with the user.

## network setup

```bash
sudo apt-get install net-tools

# https://packages.debian.org/stable/firmware-iwlwifi
# dpkg -i PACKAGE

touch /etc/wpa_supplicant/wpa_supplicant.conf
```

Add this to `/etc/network/wpa_supplicant/wpa_supplicant.conf`

```
network={
    ssid="YOUR_SSID"
    scan_ssid=1
    key_mgmt=WPA-PSK
    proto=WPA WPA2
    pairwise=CCMP TKIP
    group=CCMP TKIP WEP104 WEP40
    psk="YOUR_PASSWORD"
}
```

Add this to `/etc/network/interfaces`

```
iface wlp61s0 inet dhcp
	wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
```

If you want to scan SSID, enter this command.

```
iwlist scan
```

Helpful URL
https://wiki.debian.org/WiFi/HowToUse

```bash
sudo ifup wlp61s0
```

