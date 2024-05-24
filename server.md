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
# usermod -aG sudo Lacia
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

CentOS

```zsh
yum install policycoreutils-python-utils
semanage port -a -t ssh_port_t -p tcp 2222
firewall-cmd --zone=public --add-port=2222/tcp --permanent
firewall-cmd --reload
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
sudo mkdir /var/www/fractal.polyomino.jp
sudo chown remochan:remochan /var/www/fractal.polyomino.jp
```

⚠ build application (local computer)

```zsh
./mvnw release:clean package
rsync target/fractal-0.0.1-SNAPSHOT.jar remochan:/var/www/fractal.polyomino.jp
```

### create reverse proxy

```zsh
sudo vim /etc/nginx/sites-available/fractal.polyomino.jp.conf
```

```
upstream springbootapp {
    server localhost:8888;
}

server {
    listen 80;
    listen [::]:80;

    server_name fractal.polyomino.jp;
    access_log  /var/log/nginx/fractal.polyomino.jp;

    autoindex off;
    server_tokens off;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options nosniff;

    client_max_body_size 1k;

    proxy_redirect      off;
    proxy_set_header    Host                $host;
    proxy_set_header    X-Real-IP           $remote_addr;
    proxy_set_header    X-Forwarded-Host    $host;
    proxy_set_header    X-Forwarded-Server  $host;
    proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;

    location / {
        proxy_pass      http://springbootapp/;
    }

    error_page 401 402 403 404 /error.html;
    error_page 501 502 503 504 /error.html;
}

```

### create service

```zsh
sudo vim /etc/systemd/system/springbootapp.service
```

```
[Unit]
Description=SpringBoot Service

[Service]
User=nobody
WorkingDirectory=/var/www/fractal.polyomino.jp
ExecStart=/usr/bin/java -Xmx256m -jar /var/www/fractal.polyomino.jp/fractal-0.0.1-SNAPSHOT.jar --s    erver.port=8888
SuccessExitStatus=143
TimeoutStopSec=10
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

```zsh
sudo systemctl daemon-reload
sudo systemctl enable springbootapp.service
sudo systemctl status
```

### start in server

```zsh
sudo systemctl start springbootapp.service
sudo systemctl status
```

### install database

```zsh
sudo apt install mariadb-server
sudo systemctl restart springbootapp.service
```

### enable https

https://www.nginx.com/blog/using-free-ssltls-certificates-from-lets-encrypt-with-nginx/

```zsh
sudo apt install certbot
sudo apt install python3-certbot-nginx
certbot --nginx
sudo vim /etc/nginx/sites-available/fractal.polyomino.jp.conf
```

```
    listen 443 ssl;
    ssl_certificate     /etc/letsencrypt/live/fractal.polyomino.jp/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/fractal.polyomino.jp/privkey.pem;

    include /etc/letsencrypt/options-ssl-nginx.conf;
    if ($scheme != "https") {
        return 301 https://$host$request_uri;
    }
```

#### auto update certificate

```zsh
crontab -e
```

and add schedule

```
0 0 8 * * root /usr/bin/certbot renew --quiet --post-hook "systemctl reload nginx"
```

Raspberry Pi OS

```zsh
sudo raspi-config
```
- System Options → Boot / Auto Login → Console
- Interfacing Options → SSH
