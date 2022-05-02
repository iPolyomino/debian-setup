## update software

```bash
apt update
apt upgrade
```

## install fundamental software

```bash
apt install sudo vim tmux curl zsh
```

## create user

```bash
useradd -m remochan
adduser remochan sudo
passwd remochan
```

## enable SSH Key

```zsh
mkdir /home/remochan/.ssh
vim /home/remochan/.ssh/authorized_keys
```

### client setting

⚠ Settings for connecting **clients** (local computer)

```bash
vim ~/.ssh/config
```

```
Host remochan_server
  HostName _._._._
  port 22
  user remochan
  IdentityFile ~/.ssh/id_ed25519
```

## change shell

```bash
chsh -s /usr/bin/zsh
```

## update SSH

```zsh
sudo vim /etc/ssh/sshd_config
```

add or fix your config file

```
 Port 2222
 PermitRootLogin no
 PasswordAuthentication no
```

## lock root account

```zsh
sudo usermod -L root
```

## environment setup

```zsh
sudo apt install git
git clone https://github.com/ipolyomino/dotfiles/
ln -sf ~/.dotfiles/.zshrc ~
ln -sf ~/.dotfiles/.zsh ~
ln -sf ~/.dotfiles/.vimrc ~
```

## run webserver

```zsh
sudo apt install nginx
sudo service nginx start
```

### update index page

```zsh
sudo rm /var/www/html/index.nginx-debian.html
sudo vim /var/www/html/index.html
```

and edit

```index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>my cool website</title>
  </head>
  <body>
    Hello, World!
  </body>
</html>
```

### domain setting

add a new record in "A record" with your IP address

### update nginx settings

delete default settins

```zsh
sudo rm /etc/nginx/sites-available/default
sudo unlink /etc/nginx/sites-enable/default
```

create new website setting files

```zsh
sudo vim /etc/nginx/sites-available/fractal.polyomino.jp.conf
```

example of config file
https://www.nginx.com/resources/wiki/start/topics/examples/full/

```
server {
    listen 80;
    listen [::]:80;

    server_name fractal.polyomino.jp;
    access_log  /var/log/nginx/fractal.polyomino.jp;

    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    server_tokens off;
}
```

finally create symbolic link in "sites-available" directory and reload settins

```zsh
sudo ln -sf /etc/nginx/sites-available/fractal.polyomino.jp.conf /etc/nginx/sites-available/
sudo nginx -s reload
```

## web application server settings

### Spring Boot application

install Java Runtime Environment(jre)

```zsh
sudo apt install rsync
sudo apt install openjdk-11-jre
```

⚠ build application (local computer)

```zsh
./mvnw release:clean package
rsync target/fractal-0.0.1-SNAPSHOT.jar remochan:.
```

### create reverse proxy

```
sudo vim /etc/nginx/sites-available/fractal.polyomino.jp.conf
```

### create service

```
sudo vim /etc/systemd/system/springbootapp.service
systemctl daemon-reload
sudo systemctl enable springbootapp.service
sudo systemctl status
```

### start in server

```
sudo systemctl start springbootapp.service
sudo systemctl status
```
