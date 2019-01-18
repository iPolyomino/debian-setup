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

Helpful URL
https://github.com/zplug/zplug/blob/master/doc/guide/ja/README.md

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

Add this to `~/.gitconfig`

```
[alias]
	co = checkout
	br = branch
	st = status

[core]
	excludesfile = ~/.gitignore_global

[ghq]
	root = ~/go/src/

[user]
	email = macbookpromacbookpromacbookpro@gmail.com
	name = iPolyomino
```

Add this to `~/.gitignore_global`

```
*~

# temporary files which can be created if a process still has a handle open of a deleted file
.fuse_hidden*

# KDE directory preferences
.directory

# Linux trash folder which might appear on any partition or disk
.Trash-*

# .nfs files are created when an open file is removed but is still being accessed
.nfs*

# VisualStudioCode

.vscode/*
```
