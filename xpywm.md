# xpywm installation

https://github.com/h-ohsaki/xpywm

Install Python 3.7

```zsh
sudo apt-get install build-essential
sudo apt-get install libreadline-gplv2-dev libncursesw5-dev libssl-dev \
    libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev
cd /usr/src
sudo wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tgz
sudo tar xzf Python-3.7.3.tgz
cd Python-3.7.3
sudo ./configure --enable-optimizations
sudo make altinstall
```

Install essential package for xpy*

```zsh
sudo apt install xorg net-tools
```

Optional packages

```zsh
sudo apt install rxvt-unicode rxvt-unicode-256color
```

```zsh
sudo pip3 install xpywm xpymon xpylog
```

```zsh
startx
```
