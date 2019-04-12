# xpywm installation

http://www.lsnl.jp/~ohsaki/software/xpywm/

```zsh
wget http://www.lsnl.jp/~ohsaki/software/xpywm/Makefile
su
make install
exit
make fetch-skelton
cp skel.xinitrc ~/.xinitrc
cp skel.Xdefaults ~/.Xdefaults
cp skel.emacs ~/.emacs
```

Edit `/etc/X11/Xwrapper.config`

```
allowed_users=anybody
```

```zsh
startx
```
