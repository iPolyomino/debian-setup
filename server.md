# Server Setup Manual

This manual covers basic Debian server setup, nginx hosting, a Spring Boot
service behind nginx, and Raspberry Pi OS setup for FR24, readsb, and Pi-hole.

Replace example values before running commands:

- `remochan`: login user
- `fractal.polyomino.jp`: domain name
- `192.168.20.102`: Raspberry Pi IP address
- `2222`: SSH port

## 1. Basic Debian Setup

Run these commands as `root` or with `sudo`.

### Update Packages

```bash
apt update
apt upgrade
```

### Install Basic Tools

```bash
apt install sudo vim tmux curl zsh git
```

### Create a User

```bash
useradd -m remochan
adduser remochan sudo
passwd remochan
```

### Configure SSH Keys

On the server:

```bash
mkdir -p /home/remochan/.ssh
vim /home/remochan/.ssh/authorized_keys
chown -R remochan:remochan /home/remochan/.ssh
chmod 700 /home/remochan/.ssh
chmod 600 /home/remochan/.ssh/authorized_keys
```

On the client machine, edit `~/.ssh/config`:

```sshconfig
Host remochan_server
  HostName _._._._
  Port 2222
  User remochan
  IdentityFile ~/.ssh/id_ed25519
```

### Change the Login Shell

```bash
chsh -s /usr/bin/zsh remochan
```

### Harden SSH

Edit `/etc/ssh/sshd_config`:

```bash
sudo vim /etc/ssh/sshd_config
```

Set these values:

```sshconfig
Port 2222
PermitRootLogin no
PasswordAuthentication no
```

Restart SSH after confirming the config:

```bash
sudo sshd -t
sudo systemctl restart ssh
```

Keep the current SSH session open until a new login succeeds.

### Open the SSH Port on CentOS

Use this only on CentOS or compatible systems.

```bash
yum install policycoreutils-python-utils
semanage port -a -t ssh_port_t -p tcp 2222
firewall-cmd --zone=public --add-port=2222/tcp --permanent
firewall-cmd --reload
```

### Lock the Root Account

```bash
sudo usermod -L root
```

### Install Dotfiles

```bash
git clone https://github.com/iPolyomino/dotfiles ~/.dotfiles
ln -sf ~/.dotfiles/.zshrc ~
ln -sf ~/.dotfiles/.zsh ~
ln -sf ~/.dotfiles/.vimrc ~
```

## 2. nginx Static Site

### Install and Start nginx

```bash
sudo apt install nginx
sudo systemctl enable --now nginx
```

### Create an Index Page

```bash
sudo rm -f /var/www/html/index.nginx-debian.html
sudo vim /var/www/html/index.html
```

Example:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>My Website</title>
  </head>
  <body>
    Hello, World!
  </body>
</html>
```

### Configure DNS

Create an `A` record for the domain and point it to the server IP address.

### Configure nginx

Remove the default site:

```bash
sudo rm -f /etc/nginx/sites-available/default
sudo unlink /etc/nginx/sites-enabled/default
```

Create `/etc/nginx/sites-available/fractal.polyomino.jp.conf`:

```bash
sudo vim /etc/nginx/sites-available/fractal.polyomino.jp.conf
```

Example:

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name fractal.polyomino.jp;
    access_log /var/log/nginx/fractal.polyomino.jp.access.log;

    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    server_tokens off;
}
```

Enable the site and reload nginx:

```zsh
sudo ln -sf /etc/nginx/sites-available/fractal.polyomino.jp.conf /etc/nginx/sites-enable
sudo nginx -s reload
```

## 3. Spring Boot Behind nginx

### Install Runtime Packages

```bash
sudo apt install rsync openjdk-11-jre
sudo mkdir -p /var/www/fractal.polyomino.jp
sudo chown remochan:remochan /var/www/fractal.polyomino.jp
```

### Build and Deploy the Application

Run this on the client or build machine:

```bash
./mvnw release:clean package
rsync target/fractal-0.0.1-SNAPSHOT.jar remochan_server:/var/www/fractal.polyomino.jp/
```

### Configure nginx as a Reverse Proxy

Edit `/etc/nginx/sites-available/fractal.polyomino.jp.conf`:

```bash
sudo vim /etc/nginx/sites-available/fractal.polyomino.jp.conf
```

Example:

```nginx
upstream springbootapp {
    server 127.0.0.1:8888;
}

server {
    listen 80;
    listen [::]:80;

    server_name fractal.polyomino.jp;
    access_log /var/log/nginx/fractal.polyomino.jp.access.log;

    autoindex off;
    server_tokens off;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    client_max_body_size 1m;

    proxy_redirect off;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Server $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    location / {
        proxy_pass http://springbootapp/;
    }

    error_page 401 402 403 404 /error.html;
    error_page 501 502 503 504 /error.html;
}
```

Validate and reload nginx:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

### Create a systemd Service

Create `/etc/systemd/system/springbootapp.service`:

```bash
sudo vim /etc/systemd/system/springbootapp.service
```

Example:

```ini
[Unit]
Description=Spring Boot Application
After=network.target

[Service]
User=remochan
WorkingDirectory=/var/www/fractal.polyomino.jp
ExecStart=/usr/bin/java -Xmx256m -jar /var/www/fractal.polyomino.jp/fractal-0.0.1-SNAPSHOT.jar --server.port=8888
SuccessExitStatus=143
TimeoutStopSec=10
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable springbootapp.service
sudo systemctl start springbootapp.service
sudo systemctl status springbootapp.service
```

### Install MariaDB

```bash
sudo apt install mariadb-server
sudo systemctl restart springbootapp.service
```

## 4. HTTPS with Let's Encrypt

Install Certbot:

```bash
sudo apt install certbot python3-certbot-nginx
```

Issue and install a certificate:

```bash
sudo certbot --nginx
```

Certbot usually updates the nginx config automatically. If manual settings are
needed, add the certificate paths to the server block:

```nginx
listen 443 ssl;
ssl_certificate /etc/letsencrypt/live/fractal.polyomino.jp/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/fractal.polyomino.jp/privkey.pem;

include /etc/letsencrypt/options-ssl-nginx.conf;
```

Test renewal:

```bash
sudo certbot renew --dry-run
```

## 5. Raspberry Pi OS Base Settings

Open Raspberry Pi configuration:

```bash
sudo raspi-config
```

Recommended settings:

- `System Options` -> `Boot / Auto Login` -> `Console`
- `Interfacing Options` -> `SSH`

## 6. Raspberry Pi FR24, readsb, and Pi-hole

Target environment:

```text
Raspberry Pi 4 Model B
Raspberry Pi OS 64-bit
Debian 13 Trixie
RTL-SDR USB dongle
```

ADS-B flow:

```text
RTL-SDR USB dongle
  -> readsb
  -> Beast TCP port 30005
  -> fr24feed
  -> Flightradar24
```

DNS flow:

```text
LAN clients
  -> DNS distributed by RTX830
  -> Pi-hole
  -> upstream DNS
```

### Check the OS and USB Dongle

```bash
cat /etc/os-release
uname -m
lsusb
```

Expected values:

```text
VERSION_CODENAME=trixie
aarch64
```

### Install FR24 Feeder

Run the official installer:

```bash
wget -qO- https://fr24.com/install.sh | sudo bash -s
```

Initial settings:

```text
Receiver: 1 - DVBT Stick (USB)
Additional dump1090 arguments: empty
RAW data feed port 30002: no
Basestation data feed port 30003: no
```

Enable the service:

```bash
sudo systemctl enable fr24feed
sudo systemctl restart fr24feed
sudo systemctl status fr24feed --no-pager
fr24feed-status
```

On Trixie 64-bit, the installer may install an old 32-bit
`dump1090-mutability` package. If `fr24feed-status` shows this, switch to the
readsb setup below:

```text
FR24 Link: connected
Receiver: down
```

### Check dump1090-mutability

```bash
file /usr/bin/dump1090-mutability
```

If it shows `ELF 32-bit LSB` and `ARM EABI5`, it is an armhf binary and may not
run on a 64-bit OS. A typical error is:

```text
sudo: unable to execute /usr/bin/dump1090-mutability: No such file or directory
```

### Remove Old dump1090-mutability

```bash
sudo systemctl stop fr24feed
sudo apt remove dump1090-mutability:armhf
sudo apt --fix-broken install
sudo apt autoremove
```

If removal fails:

```bash
sudo dpkg --remove --force-remove-reinstreq dump1090-mutability:armhf
sudo apt --fix-broken install
```

To remove leftover configuration:

```bash
sudo apt purge dump1090-mutability:armhf
```

Check the package state:

```bash
dpkg -l | grep -E 'dump1090|readsb|rtl-sdr'
```

If `dump1090-mutability:armhf` is marked `rc`, the package body is removed and
only configuration files remain.

### Install and Test RTL-SDR Tools

```bash
sudo apt update
sudo apt install rtl-sdr
sudo systemctl stop fr24feed
rtl_test -t
```

Normal output:

```text
Found 1 device(s):
  0: Realtek, RTL2838UHIDIR

Using device 0: Generic RTL2832U OEM
Found Rafael Micro R820T tuner
```

For an R820T tuner, this message is not a problem:

```text
No E4000 tuner found, aborting.
```

### Try the Debian readsb Package

```bash
sudo apt install readsb rtl-sdr
sudo systemctl enable --now readsb
sudo systemctl status readsb --no-pager
```

If the Trixie package was built without RTL-SDR support, it may fail. Check logs:

```bash
sudo journalctl -u readsb -b -n 100 --no-pager
```

Unsupported RTL-SDR examples:

```text
SDR type '0' not recognized
ERROR: Unknown device type:0
```

If `rtlsdr` is missing from the supported SDR list, build readsb from source.

### Build readsb with RTL-SDR Support

Install build dependencies:

```bash
sudo apt update
sudo apt install -y git build-essential pkg-config libusb-1.0-0-dev librtlsdr-dev libzstd-dev zlib1g-dev libncurses-dev
```

Build readsb:

```bash
cd /tmp
git clone https://github.com/wiedehopf/readsb.git
cd /tmp/readsb
make clean
make RTLSDR=yes
```

If `zstd.h` is missing:

```bash
sudo apt install libzstd-dev
```

If `curses.h` is missing:

```bash
sudo apt install libncurses-dev
```

Rebuild after installing missing dependencies:

```bash
make clean
make RTLSDR=yes
```

Confirm RTL-SDR support:

```bash
./readsb --help | grep -A10 'device-type'
```

Expected output includes:

```text
use with --device-type rtlsdr
```

### Test the Built readsb Binary

```bash
sudo systemctl stop fr24feed
sudo systemctl stop readsb
cd /tmp/readsb
sudo ./readsb --device-type rtlsdr --device 0 --interactive
```

If aircraft appear, reception is working. Press `Ctrl + C` to stop.

### Install the Built readsb Binary

```bash
cd /tmp/readsb
sudo install -m 755 ./readsb /usr/local/bin/readsb
/usr/local/bin/readsb --help | grep -A10 'device-type'
```

### Use the Built Binary from systemd

Create a systemd drop-in:

```bash
sudo mkdir -p /etc/systemd/system/readsb.service.d
sudo vim /etc/systemd/system/readsb.service.d/override.conf
```

Content:

```ini
[Service]
ExecStart=
ExecStart=/usr/local/bin/readsb $RECEIVER_OPTIONS $DECODER_OPTIONS $NET_OPTIONS $JSON_OPTIONS --write-json /run/readsb --quiet
```

Reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl enable readsb
sudo systemctl restart readsb
```

Verify the override:

```bash
systemctl cat readsb
systemctl show readsb -p ExecStart --no-pager
sudo systemctl status readsb --no-pager
```

Normal logs include:

```text
rtlsdr: using device #0
Detached kernel driver
Found Rafael Micro R820T tuner
```

### Check the Beast Output Port

```bash
sudo ss -lntp | grep 30005
```

Normal output:

```text
LISTEN 0 4096 0.0.0.0:30005
LISTEN 0 4096 [::]:30005
```

Port `30005/TCP` is the Beast binary output port.

### Connect FR24 to readsb

Reconfigure FR24:

```bash
sudo fr24feed --reconfigure
```

Use these settings:

```text
Receiver: 4 - ModeS Beast
Connection: 1 - Network connection
Host: 127.0.0.1
Port: 30005
```

The config should look like one of these forms:

```ini
receiver="beast-tcp"
host="127.0.0.1:30005"
```

```ini
receiver="beast-tcp"
host="127.0.0.1"
port="30005"
```

Check the sharing key:

```bash
sudo grep '^fr24key=' /etc/fr24feed.ini
```

Do not publish the sharing key. If it is empty, copy the sharing key from the
old environment.

Validate and restart:

```bash
sudo /usr/bin/fr24feed --validate-config --config-file=/etc/fr24feed.ini
sudo systemctl reset-failed fr24feed
sudo systemctl enable fr24feed
sudo systemctl restart fr24feed
```

### Check FR24

```bash
fr24feed-status
```

Normal output:

```text
FR24 Feeder/Decoder Process: running.
FR24 Link: connected [UDP].
FR24 Radar: T-XXXXXXX.
FR24 Tracked AC: 3.
Receiver: connected (2064 MSGS/0 SYNC).
```

Check these fields:

```text
FR24 Feeder/Decoder Process: running
FR24 Link: connected
Receiver: connected
FR24 Tracked AC: 1 or more
```

With Beast TCP, `0 SYNC` can be acceptable if `Tracked AC` increases.

Check automatic startup:

```bash
systemctl is-enabled readsb fr24feed
systemctl is-active readsb fr24feed
```

Expected output:

```text
enabled
enabled
active
active
```

## 7. Pi-hole

### Prepare the Raspberry Pi

Check the IP address and route:

```bash
ip -br addr
ip route
```

Use a static IP address or a DHCP reservation on the router. Example:

```text
192.168.20.102
```

Check for port 53 conflicts:

```bash
sudo ss -lntup | grep ':53 '
```

If there is no output, continue.

### Install Pi-hole

```bash
cd /tmp
wget -O basic-install.sh https://install.pi-hole.net
less basic-install.sh
sudo bash basic-install.sh
```

Example settings:

```text
Interface: eth0
IP address: 192.168.20.102
Upstream DNS: Quad9
Web admin interface: Yes
Query logging: Yes
Pi-hole DHCP server: No
```

If another router, such as an RTX830, provides DHCP, do not enable Pi-hole DHCP.

### Check Pi-hole

```bash
pihole status
sudo systemctl status pihole-FTL --no-pager
sudo ss -lntup | grep ':53 '
```

Test DNS:

```bash
dig example.com @127.0.0.1
dig example.com @192.168.20.102
```

Install `dig` if needed:

```bash
sudo apt install dnsutils
```

Admin URL:

```text
http://192.168.20.102/admin/
```

### Change the Pi-hole Password

For Pi-hole v6:

```bash
sudo pihole setpassword
```

Enter the password interactively. Do not put the password directly in the
command line because it can remain in shell history.

### Restore Pi-hole Settings

If you have a Teleporter backup from an old Pi-hole instance, restore it from
the admin UI:

```text
Settings -> Teleporter -> Import
```

Check these settings after restore:

```text
Upstream DNS
Listen interface
Local DNS Records
Conditional Forwarding
Adlists
Allowlist
Denylist
DHCP server is disabled
```

### Distribute Pi-hole DNS from the Router

After Pi-hole works, configure the router DHCP settings to distribute the
Pi-hole IP address as DNS.

RTX830 example:

```text
administrator
dhcp scope option 10 dns=192.168.20.102
dhcp scope option 20 dns=192.168.20.102
save
```

Check the router config:

```text
show config | grep "dhcp scope option"
```

Reconnect Wi-Fi or renew the DHCP lease on clients.

On macOS, flush the DNS cache:

```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

Watch Pi-hole queries:

```bash
pihole tail
```

## 8. Final Checks

Reboot:

```bash
sudo reboot
```

After reconnecting:

```bash
systemctl is-active readsb fr24feed pihole-FTL
fr24feed-status
pihole status
sudo systemctl status readsb --no-pager
sudo ss -lntup | grep -E ':53 |:30005'
```

Expected service state:

```text
active
active
active
```

## 9. Maintenance Commands

### readsb

```bash
sudo systemctl status readsb --no-pager
sudo journalctl -u readsb -b -n 100 --no-pager
sudo ss -lntp | grep 30005
```

### FR24

```bash
fr24feed-status
sudo systemctl status fr24feed --no-pager
sudo journalctl -u fr24feed -b -n 100 --no-pager
```

### Pi-hole

```bash
pihole status
sudo systemctl status pihole-FTL --no-pager
pihole tail
```

### Rebuild readsb

`/usr/local/bin/readsb` is not managed by APT. Rebuild it manually when needed:

```bash
cd /tmp
rm -rf readsb
git clone https://github.com/wiedehopf/readsb.git
cd readsb
make clean
make RTLSDR=yes
sudo install -m 755 ./readsb /usr/local/bin/readsb
sudo systemctl restart readsb
```

Verify:

```bash
/usr/local/bin/readsb --help | grep -A10 'device-type'
sudo systemctl status readsb --no-pager
```

## 10. Notes

- Do not publish `fr24key` from `/etc/fr24feed.ini`.
- Do not let multiple processes open the RTL-SDR dongle at the same time.
- `readsb` owns the RTL-SDR dongle.
- `fr24feed` should read Beast TCP from `127.0.0.1:30005`.
- Use `receiver="beast-tcp"` for FR24.
- Avoid switching FR24 back to `receiver="dvbt"` on Trixie 64-bit.
- `/usr/local/bin/readsb` is outside APT management.
- Use a fixed IP address for the Pi-hole Raspberry Pi.
- If the router provides DHCP, keep Pi-hole DHCP disabled.
- Do not switch router DNS to Pi-hole until Pi-hole has passed local tests.
