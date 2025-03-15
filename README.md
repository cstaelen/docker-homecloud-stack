# Homecloud docker stack

Include services:
- Caddy
- Dashy
- Bitwarden
- Photoprism
- Overseerr
- MariaDB
- Matomo
- Tidal connect
- Plexamp connect headless
- Gotify
- Nextcloud AIO
- Portainer
- Glances

## Disks

`sudo fdisk -l` 
- /dev/sda -> backup
- /dev/sdb -> storage

`sudo mkdir /media/storage`
`sudo mkdir /media/backup`

```bash
sudo nano /etc/fstab
```
add :
```
UUID=da8ca302-9c04-4919-a63e-68290a1a23e3 /media/storage ext4 defaults 0
UUID=0bbb81c9-f876-4599-ba1c-e24933ed43af /media/backup ext4 defaults 0
```

## Docker

Install :

```bash
 curl -fsSL https://get.docker.com -o get-docker.sh
 sudo sh ./get-docker.sh --dry-run
```

If `permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock` occurred, create docker and add user into :
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

## Daemon

```bash
sudo systemctl edit --force --full homecloud.service
```

Add content :

```bash
[Unit]
Description=Docker Compose Homecloud Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/media/storage/homecloud
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

Enable service

 ```bash
sudo systemctl enable --now homecloud.service
 ```
## Power red light

```bash
sudo nano /boot/firmware/config.txt
```

add 

```bash
dtpram=act_led_trigger=heartbeat
dtpram=pwr_led_trigger=none
```

## Nextcloud

Scan files

```bash
sudo docker exec --user www-data -it nextcloud php occ files:scan-app-data 
sudo docker exec --user www-data -it nextcloud php occ files:scan --all
```

```php
[
    ...
    'trusted_domains' => array (
        0 => 'https://home.cl-st.me',
    ),
    'overwrite.cli.url' => 'https://home.cl-st.me',
    'overwriteprotocol' => 'http',
    ...
]
```

## Backup cron

Edit `crontab` :
```bash
sudo crontab -e
```

add :
```bash
0 3 * * * cd /media/storage/homecloud && sh /media/storage/homecloud/backup_docker.sh > /media/backup/homecloud/.log-bck
```

Restart cron service: 
```bash
sudo systemctl restart cron.service
```