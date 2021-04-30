# debian-setup

Do the following with the root.

```bash
apt install sudo vim tmux emacs w3m curl
```

## sudoers setup

```bash
adduser hagi sudo
```

---

Do the following with the user.

## neovim setup

```bash
sudo apt install fuse
sudo pip3 install nvim
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
chmod u+x nvim.appimage
sudo mv nvim.appimage /usr/local/bin/nvim
```

## network setup

```bash
sudo apt install wireless-tools

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
sudo apt install git
git clone https://github.com/iPolyomino/dotfiles ~/.dotfiles
./.dotfiles/link.sh
```

### zsh setup

```bash
sudo apt install zsh zsh-doc
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

#### vimplug setup

```zsh
sudo apt-get install vim-gtk
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

#### dein.vim setup

```zsh
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
sh ./installer.sh ~/.cache/dein
```

### fzf setup

```zsh
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### rust setup

```zsh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

#### Racer setup

```zsh
sudo apt install build-essential
rustup toolchain add nightly
cargo +nightly install racer
```

https://github.com/racer-rust/racer

### anyenv setup

```zsh
git clone https://github.com/anyenv/anyenv ~/.anyenv
exec $SHELL -l
anyenv install --init
```

```zsh
sudo apt install build-essential
```

#### pyenv setup

```zsh
sudo apt -y install gcc make libssl-dev libbz2-dev libreadline-dev libsqlite3-dev zlib1g-dev libffi-dev
anyenv install pyenv
exec $SHELL -l
pyenv install 3.9.4
pyenv global $_
```

optional setup

```zsh
pip3 install pynvim
```

#### phpenv setup

```zsh
sudo apt install libcurl4-nss-dev libcurl4-gnutls-dev libjpeg-dev re2c libxml2-dev libtidy-dev libxslt-dev libmcrypt-dev  libreadline-dev libpng-dev
anyenv install phpenv
exec $SHELL -l
phpenv install 7.2.11
phpenv global $_
```

#### nodenv setup

```zsh
anyenv install nodenv
exec $SHELL -l
touch $(nodenv root)/default-packages
nodenv install 14.16.1
nodenv global $_
```

optional setup

```zsh
npm i -g firebase-tools http-server npm-check-updates neovim prettier
```

#### goenv setup

```zsh
anyenv install goenv
exec $SHELL -l
goenv install 1.16.3
mkdir ~/go
echo 'export GOPATH="$HOME/go"' >> ~/.zshrc
echo 'export PATH="$PATH:$GOPATH/bin"' >> ~/.zshrc
echo 'export GOENV_DISABLE_GOPATH=1' >> ~/.zshrc
source ~/.zshrc
exec $SHELL -l
goenv global 1.16.3
```

optional setup

```zsh
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

### If you want to install with `apt`

_python_

```zsh
sudo apt install python3 python3-dev python3-pip
```

_php_

```zsh
sudo apt install php
```

_node_

```zsh
sudo apt install nodejs npm
```

_go_

```zsh
sudo apt install golang-go
```

## spacemacs setup

```zsh
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
```

## additional packages

```zsh
sudo apt install xsel firefox-esr
```

### Install Firefox Developer Edition

Download from website
https://www.mozilla.org/en-US/firefox/channel/desktop/

```zsh
sudo apt install libdbus-glib-1-2
```

```zsh
tar -xvf firefox-*.tar.bz2
sudo mv /home/hagi/Downloads/firefox /opt
sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox
sudo touch /usr/share/applications/firefox-developer.desktop
```

Edit config file

```
[Desktop Entry]
Name=Firefox Developer
GenericName=Firefox Developer Edition
Exec=/usr/local/bin/firefox
Terminal=false
Icon=/opt/firefox/browser/chrome/icons/default/default48.png
Type=Application
Categories=Application;Network;X-Developer;
Comment=Firefox Developer Edition Web Browser
```

Update default browser

```zsh
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/bin/firefox 500
sudo update-alternatives --config x-www-browser
```

### Install Alacritty

```zsh
sudo apt install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3
git clone git@github.com:alacritty/alacritty.git
cd alacritty
cargo install cargo-deb
cargo deb --install -p alacritty
```

### Install bat command

Download from website
https://github.com/sharkdp/bat/releases

```zsh
sudo dpkg -i bat_*_amd64.deb
```

## generate ssh-key

```zsh
ssh-keygen -t ed25519
```

Edit config file

```
Host github.com
    HostName github.com
    IdentityFile ~/.ssh/github_ed25519
```

## skk

```zsh
sudo apt install ddskk skkdic uim uim-skk dbskkd-cdb skkdic-cdb
echo "(define default-im-name 'skk)" > ~/.uim
```

## mozc

```zsh
sudo apt install fcitx fcitx-mozc dbus-x11
```

```zsh
im-config
```

Select `fcitx`

```zsh
fcitx-configtool
```

Add `mozc`

```zsh
$ sudo apt install fcitx fcitx-mozc dbus-x11
# im-config -> select "fcitx"
$ fcitx-configtool
# + mozc
```

Edit `~/.xinitrc`

```
export DefaultImModule=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
fcitx-autostart
```

## emacs mozc

```zsh
sudo apt install emacs-mozc
```

Edit `~/.emacs`

```elisp
;;mozc
(require 'mozc)
(setq default-input-method "japanese-mozc")
```

### Docker

https://docs.docker.com/install/linux/docker-ce/debian/

use docker without sudo

```zsh
adduser hagi docker
```

### Docker Compose

https://docs.docker.com/compose/install/

## mew

```zsh
sudo apt install mew
```

## pdf viewer setup

```zsh
sudo apt install mupdf
xdg-mime default mupdf.desktop application/pdf
```

## i3 install

```zsh
sudo apt install i3 i3status dmenu feh i3lock
```

## urxvt resize font

https://github.com/simmel/urxvt-resize-font

```
mkdir ~/.urxvt/ext
cd $_
wget https://raw.githubusercontent.com/simmel/urxvt-resize-font/master/resize-font
echo 'urxvt.perl-ext-common: resize-font' >> ~/.Xdefaults
```
