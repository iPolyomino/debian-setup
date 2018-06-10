#!/bin/sh

sudo apt-get update
sudo apt-get upgrade

sudo apt-get install zsh zsh-doc

sudo chsh -s $(which zsh)

sudo apt-get install emacs24 emacs24-el
cat emacs.txt >> ~/.emacs

sudo apt-get install vim
cat vimrc.txt >> ~/.vimrc

sudo apt-get install xsel
echo 'alias pbcopy="xsel -i -b"' >> ~/.zshrc
echo 'alias pbpaste="xsel -o -b"' >> ~/.zshrc

sudo apt-get install git curl tmux fbterm gawk

curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

cat zplug.txt >> ~/.zshrc
source ~/.zshrc
zplug install

sudo apt-get install golang
mkdir ~/go
echo 'export GOPATH="$HOME/go"' >> ~/.zshrc
echo 'export PATH="$PATH:$HOME/go/bin"' >> ~/.zshrc

source ~/.zshrc

go get -u github.com/junegunn/fzf
go get -u github.com/motemen/ghq

cat ghq-fzf-setup.txt >> ~/.zshrc

curl https://sh.rustup.rs -sSf | sh
source $HOME/.cargo/env
echo 'export PATH="$PATH:$HOME/.cargo/bin"' >> ~/.zshrc

sudo apt-get install xserver-xorg xbase-clients xterm twm rxvt-ml
