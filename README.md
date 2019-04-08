# debian-setup

Do the following with the root.

```bash
apt-get install sudo vim tmux emacs25 w3m curl
```

## sudoers setup

```bash
export EDITOR=/usr/bin/vim
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
    priority=1
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

## nocaps setup

Edit `/etc/default/keyboard`

```
XKBOPTIONS="ctrl:nocaps"
```

## environment setup

```bash
sudo apt-get install git
git clone -b pure-debian https://github.com/iPolyomino/dotfiles
./dotfiles/link.sh
```

### zsh setup

```bash
sudo apt-get install zsh zsh-doc
chsh -s /usr/bin/zsh
```

#### zplug setup 

```zsh
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

zplug install
zplug load
```

Helpful URL
https://github.com/zplug/zplug/blob/master/doc/guide/ja/README.md

### rust setup

```zsh
curl https://sh.rustup.rs -sSf | sh
```

### anyenv setup

```zsh
git clone https://github.com/riywo/anyenv ~/.anyenv
echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.zprofile
echo 'eval "$(anyenv init -)"' >> ~/.zprofile
exec $SHELL -l
```

```zsh
sudo apt-get install build-essential
```

#### pyenv setup

```zsh
sudo apt-get -y install gcc make libssl-dev libbz2-dev libreadline-dev libsqlite3-dev zlib1g-dev libffi-dev
anyenv install pyenv
exec $SHELL -l
pyenv install 2.7.15
pyenv install 3.7.2
pyenv install anaconda3-5.3.1
pyenv global 3.7.2
```

#### phpenv setup

```zsh
sudo apt-get install libcurl4-nss-dev libcurl4-gnutls-dev libjpeg-dev re2c libxml2-dev libtidy-dev libxslt-dev libmcrypt-dev  libreadline-dev libpng-dev
anyenv install phpenv
exec $SHELL -l
phpenv install 7.2.11
phpenv global 7.2.11
```

#### ndenv setup

```zsh
anyenv install ndenv
exec $SHELL -l
ndenv install v10.15.0
ndenv global v10.15.0
```

optional setup

```zsh
npm i -g prettier
```

#### goenv setup

```zsh
anyenv install goenv
exec $SHELL -l
goenv install 1.11.4
mkdir ~/go
echo 'export GOPATH="$HOME/go"' >> ~/.zshrc
echo 'export PATH="$PATH:$HOME/go/bin"' >> ~/.zshrc
source ~/.zshrc
```

optional setup

```zsh
go get -u github.com/junegunn/fzf
go get -u github.com/motemen/ghq
```

Add this to `~/.zshrc`

```
function ghq-fzf() {
  local selected_dir=$(ghq list | fzf --query="$LBUFFER")

  if [ -n "$selected_dir" ]; then
    BUFFER="cd $(ghq root)/${selected_dir}"
    zle accept-line
  fi

  zle reset-prompt
}

zle -N ghq-fzf
bindkey "^g" ghq-fzf
```

### If you want to install with `apt-get`

_python_

```zsh
sudo apt-get install python3 python3-dev python3-dev
```

_php_

```zsh
sudo apt-get install php
```

_node_

```zsh
sudo apt-get install nodejs npm
```

_go_

```zsh
sudo apt-get install golang-go
```

## spacemacs setup

```zsh
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
```

## additional packages

```zsh
sudo apt-get install xsel firefox-esr
```

## generate ssh-key

```zsh
ssh-keygen -t rsa -b 4096 -C "foobar@polyomino.jp"
```

Edit config file

```
Host github.com
    HostName github.com
    IdentityFile ~/.ssh/github_rsa
```
