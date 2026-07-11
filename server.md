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


# Raspberry Pi OS Trixie 64-bit に FR24・readsb・Pi-hole を構築する手順

対象環境：

```text
Raspberry Pi 4 Model B
Raspberry Pi OS 64-bit
Debian 13 Trixie
RTL-SDR USBドングル
```

構成：

```text
RTL-SDR USBドングル
        ↓
readsb
        ↓ Beast TCP / 30005
fr24feed
        ↓
Flightradar24
```

DNS構成：

```text
LAN内端末
   ↓
RTX830からDNS配布
   ↓
Pi-hole
   ↓
上流DNS
```

---

# 1. 事前確認

OSとCPUアーキテクチャを確認する。

```sh
cat /etc/os-release
uname -m
```

想定：

```text
VERSION_CODENAME=trixie
aarch64
```

USBドングルを接続し、認識を確認する。

```sh
lsusb
```

---

# 2. FR24 feederをインストール

FR24公式インストーラーを実行する。

```sh
wget -qO- https://fr24.com/install.sh | sudo bash -s
```

初回設定では、ひとまず次のように選択する。

```text
Receiver:
1 - DVBT Stick (USB)

Additional dump1090 arguments:
空欄

RAW data feed port 30002:
no

Basestation data feed port 30003:
no
```

設定後、サービスを有効化する。

```sh
sudo systemctl enable fr24feed
sudo systemctl restart fr24feed
```

状態確認：

```sh
sudo systemctl status fr24feed --no-pager
fr24feed-status
```

Trixie 64-bit環境では、FR24インストーラーが32bit armhf版の古い `dump1090-mutability` を入れることがある。

次のように `Receiver: down` となる場合は、以降のreadsb構成へ切り替える。

```text
FR24 Link: connected
Receiver: down
```

---

# 3. dump1090-mutabilityの問題を確認

```sh
file /usr/bin/dump1090-mutability
```

次のように表示される場合、32bit armhf版である。

```text
ELF 32-bit LSB
ARM EABI5
interpreter /lib/ld-linux-armhf.so.3
```

現在のOSがarm64なら、そのままでは実行できない。

実行時に次のエラーになることがある。

```text
sudo: unable to execute /usr/bin/dump1090-mutability:
No such file or directory
```

---

# 4. 古いdump1090-mutabilityを削除

FR24を停止する。

```sh
sudo systemctl stop fr24feed
```

パッケージを削除する。

```sh
sudo apt remove dump1090-mutability:armhf
sudo apt --fix-broken install
sudo apt autoremove
```

削除できない場合：

```sh
sudo dpkg --remove --force-remove-reinstreq \
  dump1090-mutability:armhf

sudo apt --fix-broken install
```

残った設定も削除する場合：

```sh
sudo apt purge dump1090-mutability:armhf
```

確認：

```sh
dpkg -l | grep -E 'dump1090|readsb|rtl-sdr'
```

`dump1090-mutability:armhf` が `rc` の場合、本体は削除済みで設定だけ残っている。

---

# 5. RTL-SDRツールをインストール

```sh
sudo apt update
sudo apt install rtl-sdr
```

USBドングルをテストする。

```sh
sudo systemctl stop fr24feed
rtl_test -t
```

正常な例：

```text
Found 1 device(s):
  0: Realtek, RTL2838UHIDIR

Using device 0: Generic RTL2832U OEM
Found Rafael Micro R820T tuner
```

次の表示は、R820Tチューナーを使っている場合は異常ではない。

```text
No E4000 tuner found, aborting.
```

---

# 6. Debian版readsbをインストール

```sh
sudo apt install readsb rtl-sdr
```

サービスを起動する。

```sh
sudo systemctl enable --now readsb
sudo systemctl status readsb --no-pager
```

Trixieのパッケージ版readsbがRTL-SDR対応なしでビルドされている場合、起動に失敗する。

ログ確認：

```sh
sudo journalctl -u readsb -b -n 100 --no-pager
```

次のようなエラーなら、RTL-SDR非対応版である。

```text
SDR type '0' not recognized
ERROR: Unknown device type:0
```

また、対応デバイス一覧に `rtlsdr` が表示されない。

```text
supported SDR types are:
  modesbeast
  gnshulc
  ifile
  none
```

この場合はreadsbをRTL-SDR対応でソースビルドする。

---

# 7. readsbのビルド依存関係を入れる

```sh
sudo apt update

sudo apt install -y \
  git \
  build-essential \
  pkg-config \
  libusb-1.0-0-dev \
  librtlsdr-dev \
  libzstd-dev \
  zlib1g-dev \
  libncurses-dev
```

---

# 8. readsbをRTL-SDR対応でビルド

```sh
cd /tmp

git clone https://github.com/wiedehopf/readsb.git

cd /tmp/readsb
```

ビルドする。

```sh
make clean
make RTLSDR=yes
```

次のエラーが出る場合：

```text
fatal error: zstd.h: No such file or directory
```

対応：

```sh
sudo apt install libzstd-dev
```

次のエラーが出る場合：

```text
fatal error: curses.h: No such file or directory
```

対応：

```sh
sudo apt install libncurses-dev
```

依存関係を追加した後、再ビルドする。

```sh
make clean
make RTLSDR=yes
```

---

# 9. RTL-SDR対応を確認

```sh
./readsb --help | grep -A10 'device-type'
```

次が表示されれば成功。

```text
use with --device-type rtlsdr
```

---

# 10. ビルドしたreadsbを手動テスト

既存サービスを停止する。

```sh
sudo systemctl stop fr24feed
sudo systemctl stop readsb
```

手動起動する。

```sh
cd /tmp/readsb

sudo ./readsb \
  --device-type rtlsdr \
  --device 0 \
  --interactive
```

航空機一覧が表示されれば受信できている。

終了：

```text
Ctrl + C
```

---

# 11. ビルド版readsbをインストール

```sh
cd /tmp/readsb

sudo install -m 755 \
  ./readsb \
  /usr/local/bin/readsb
```

確認：

```sh
/usr/local/bin/readsb --help |
  grep -A10 'device-type'
```

---

# 12. systemdでビルド版readsbを使用

Debianパッケージのサービスは `/usr/bin/readsb` を使うため、systemdのdrop-in設定で上書きする。

```sh
sudo mkdir -p \
  /etc/systemd/system/readsb.service.d
```

設定ファイルを作る。

```sh
sudo vim \
  /etc/systemd/system/readsb.service.d/override.conf
```

内容：

```ini
[Service]
ExecStart=
ExecStart=/usr/local/bin/readsb $RECEIVER_OPTIONS $DECODER_OPTIONS $NET_OPTIONS $JSON_OPTIONS --write-json /run/readsb --quiet
```

反映：

```sh
sudo systemctl daemon-reload
sudo systemctl enable readsb
sudo systemctl restart readsb
```

確認：

```sh
systemctl cat readsb
```

末尾に次が表示されることを確認する。

```ini
# /etc/systemd/system/readsb.service.d/override.conf

[Service]
ExecStart=
ExecStart=/usr/local/bin/readsb ...
```

実際の実行コマンドを確認する。

```sh
systemctl show readsb \
  -p ExecStart \
  --no-pager
```

状態確認：

```sh
sudo systemctl status readsb --no-pager
```

正常な例：

```text
Active: active (running)
```

ログには次のような表示が出る。

```text
rtlsdr: using device #0
Detached kernel driver
Found Rafael Micro R820T tuner
```

---

# 13. readsbのBeast出力を確認

```sh
sudo ss -lntp | grep 30005
```

正常な例：

```text
LISTEN 0 4096 0.0.0.0:30005
LISTEN 0 4096 [::]:30005
```

`30005/TCP` はBeast binary形式の出力ポート。

---

# 14. FR24をreadsbへ接続

FR24設定をやり直す。

```sh
sudo fr24feed --reconfigure
```

受信機は次を選ぶ。

```text
4 - ModeS Beast
```

接続方式：

```text
1 - Network connection
```

接続先：

```text
Host: 127.0.0.1
Port: 30005
```

設定ファイルは概ね次になる。

```ini
receiver="beast-tcp"
host="127.0.0.1:30005"
```

FR24のバージョンによっては次の形式になることもある。

```ini
receiver="beast-tcp"
host="127.0.0.1"
port="30005"
```

Sharing Keyを確認する。

```sh
sudo grep '^fr24key=' /etc/fr24feed.ini
```

値が空なら、旧環境のSharing Keyを設定する。

Sharing Keyは外部へ公開しないこと。

設定検証：

```sh
sudo /usr/bin/fr24feed \
  --validate-config \
  --config-file=/etc/fr24feed.ini
```

起動：

```sh
sudo systemctl reset-failed fr24feed
sudo systemctl enable fr24feed
sudo systemctl restart fr24feed
```

---

# 15. FR24の動作確認

```sh
fr24feed-status
```

正常な例：

```text
FR24 Feeder/Decoder Process: running.
FR24 Link: connected [UDP].
FR24 Radar: T-XXXXXXX.
FR24 Tracked AC: 3.
Receiver: connected (2064 MSGS/0 SYNC).
```

確認ポイント：

```text
FR24 Feeder/Decoder Process: running
FR24 Link: connected
Receiver: connected
FR24 Tracked AC: 1以上
```

Beast TCP構成では `0 SYNC` のままでも、`Tracked AC` が増えていれば受信・デコード・送信は成立している。

自動起動確認：

```sh
systemctl is-enabled readsb fr24feed
systemctl is-active readsb fr24feed
```

期待値：

```text
enabled
enabled
active
active
```

---

# 16. Pi-holeのインストール前確認

Raspberry PiのIPアドレスを確認する。

```sh
ip -br addr
ip route
```

Pi-holeを使用するRaspberry Piには、固定IPまたはルーター側のDHCP予約を設定しておく。

例：

```text
192.168.20.102
```

ポート53の競合を確認する。

```sh
sudo ss -lntup | grep ':53 '
```

何も表示されなければ、そのまま進められる。

---

# 17. Pi-holeをインストール

公式インストーラーを取得する。

```sh
cd /tmp

wget -O basic-install.sh \
  https://install.pi-hole.net
```

必要なら内容を確認する。

```sh
less basic-install.sh
```

実行：

```sh
sudo bash basic-install.sh
```

設定例：

```text
Interface:
eth0

IP address:
192.168.20.102

Upstream DNS:
Quad9

Web admin interface:
Yes

Query logging:
Yes

Pi-hole DHCP server:
No
```

RTX830など別のルーターがDHCPを担当している場合、Pi-holeのDHCP機能は有効にしない。

---

# 18. Pi-holeの状態確認

```sh
pihole status
```

サービス確認：

```sh
sudo systemctl status \
  pihole-FTL \
  --no-pager
```

DNSポート確認：

```sh
sudo ss -lntup | grep ':53 '
```

DNS問い合わせテスト：

```sh
dig example.com @127.0.0.1
dig example.com @192.168.20.102
```

`dig` がない場合：

```sh
sudo apt install dnsutils
```

管理画面：

```text
http://192.168.20.102/admin/
```

---

# 19. Pi-holeの管理パスワード変更

Pi-hole v6：

```sh
sudo pihole setpassword
```

対話形式で新しいパスワードを入力する。

パスワードをコマンド引数へ直接書くとシェル履歴へ残るため、対話形式を推奨する。

---

# 20. Pi-hole設定を復元

旧Pi-holeのTeleporterバックアップがある場合、管理画面から復元する。

```text
Settings
→ Teleporter
→ Import
```

復元後に確認する項目：

```text
上流DNS
Listen interface
Local DNS Records
Conditional Forwarding
広告リスト
許可リスト
拒否リスト
DHCP機能が無効であること
```

---

# 21. ルーターからPi-holeをDNSとして配布

Pi-holeの動作確認が終わってから、ルーターのDHCP設定でPi-holeのIPアドレスをDNSとして配布する。

RTX830の例：

```text
administrator
dhcp scope option 10 dns=192.168.20.102
dhcp scope option 20 dns=192.168.20.102
save
```

確認：

```text
show config | grep "dhcp scope option"
```

クライアント端末はWi-Fi再接続またはDHCPリース更新を行う。

macOSのDNSキャッシュ削除：

```sh
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

Pi-holeで問い合わせを確認する。

```sh
pihole tail
```

---

# 22. 再起動後の最終確認

```sh
sudo reboot
```

再接続後：

```sh
systemctl is-active \
  readsb \
  fr24feed \
  pihole-FTL
```

期待値：

```text
active
active
active
```

FR24確認：

```sh
fr24feed-status
```

Pi-hole確認：

```sh
pihole status
```

readsb確認：

```sh
sudo systemctl status readsb --no-pager
```

ポート確認：

```sh
sudo ss -lntup |
  grep -E ':53 |:30005'
```

---

# 23. 保守用コマンド

## readsb

```sh
sudo systemctl status readsb --no-pager

sudo journalctl \
  -u readsb \
  -b \
  -n 100 \
  --no-pager

sudo ss -lntp | grep 30005
```

## FR24

```sh
fr24feed-status

sudo systemctl status \
  fr24feed \
  --no-pager

sudo journalctl \
  -u fr24feed \
  -b \
  -n 100 \
  --no-pager
```

## Pi-hole

```sh
pihole status

sudo systemctl status \
  pihole-FTL \
  --no-pager

pihole tail
```

---

# 24. readsbを更新・再ビルドする場合

`/usr/local/bin/readsb` はAPTでは更新されないため、必要に応じて手動で再ビルドする。

```sh
cd /tmp

rm -rf readsb

git clone \
  https://github.com/wiedehopf/readsb.git

cd readsb

make clean
make RTLSDR=yes

sudo install -m 755 \
  ./readsb \
  /usr/local/bin/readsb

sudo systemctl restart readsb
```

確認：

```sh
/usr/local/bin/readsb --help |
  grep -A10 'device-type'

sudo systemctl status readsb --no-pager
```

---

# 25. 注意事項

* `/etc/fr24feed.ini` の `fr24key` は公開しない。
* RTL-SDRドングルを複数のプロセスから同時に開かない。
* USBドングルを使用するのは `readsb`。
* `fr24feed` はUSBドングルを直接使わず、`127.0.0.1:30005` のBeast TCP出力を受信する。
* FR24の設定は `receiver="beast-tcp"` を使用する。
* `receiver="dvbt"` に戻すと、古い `dump1090-mutability` を使おうとして動作しない可能性がある。
* `/usr/local/bin/readsb` はAPT管理外のため、更新は手動で行う。
* Pi-hole用Raspberry PiのIPアドレスは固定する。
* ルーターがDHCPを担当する場合、Pi-holeのDHCP機能は有効にしない。
* Pi-holeが正常に動作するまでは、ルーターの配布DNSをPi-holeへ切り替えない。
