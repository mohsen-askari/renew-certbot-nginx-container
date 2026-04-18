# Certbot SSL Auto Renewal for Nginx Docker Container

A simple and production-friendly Bash script to automatically renew Let's Encrypt SSL certificates inside an Nginx Docker container using Certbot.

This script is designed to be executed from the host machine via cron and then perform all required checks and renewal operations inside the target Docker container.

---

## Features

- Checks whether the Docker container exists
- Checks whether the container is running
- Installs `certbot` and `python3-certbot-nginx` automatically if missing
- Detects whether any existing renewal configuration is available
- Runs `certbot renew` only when needed
- Reloads Nginx only after a successful certificate renewal
- Avoids unnecessary reloads when no certificate is due
- Clean log output with author signature

---

## Use Case

This script is useful when:

- Nginx is running inside a Docker container
- Certbot is installed inside the same container
- SSL certificates are already issued and stored in `/etc/letsencrypt`
- You want a lightweight and reliable cron-based auto-renewal flow

---

## Script

Create the script file:

```bash
sudo nano /usr/local/bin/renew-certbot-nginx-container.sh
```

---

## Cron Job
To execute the script every day at 03:00 AM Dubai time, open root crontab:

```bash
sudo crontab -e
```
Add:

```bash
CRON_TZ=Asia/Dubai
0 3 * * * /usr/local/bin/renew-certbot-nginx-container.sh >> /var/log/renew-certbot-nginx-container.log 2>&1
```
This will:

- run the script daily at 03:00 AM
- use Dubai timezone
- append logs to:

```bash
/var/log/renew-certbot-nginx-container.log

```

