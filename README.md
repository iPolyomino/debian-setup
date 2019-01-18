# debian-setup

Do the following with the root.

```bash
apt-get install sudo vim tmux emacs25 w3m
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

## environment setup

```bash
sudo apt-get install git
git clone https://github.com/iPolyomino/dotfiles
git checkout pure-debian
~/dotfiles/link.sh
```

### zsh setup

```bash
sudo apt-get install zsh zsh-doc
chsh -s /usr/bin/zsh
```

#### zplug setup 

```zsh
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
```

Add this to `.zshrc`

```zsh
# zplug settings
source ~/.zplug/init.zsh

zplug "zplug/zplug", hook-build:'zplug --self-manage'
zplug "mafredri/zsh-async"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "chrissicool/zsh-256color"
zplug "zsh-users/zsh-syntax-highlighting"

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load
```

### anyenv setup

```zsh
git clone https://github.com/riywo/anyenv ~/.anyenv
echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.zprofile
echo 'eval "$(anyenv init -)"' >> ~/.zprofile
exec $SHELL -l
```
