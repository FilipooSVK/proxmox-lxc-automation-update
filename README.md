# 🚀 LXC Update Automation Script (Proxmox)
![Platform](https://img.shields.io/badge/Platform-Proxmox%20VE%20%7C%20Linux-blue)
![Script](https://img.shields.io/badge/Script-Bash-0a7ea4)
![Automation](https://img.shields.io/badge/Automation-Cron%20Ready-orange)
![Notifications](https://img.shields.io/badge/Notifications-Discord%20Webhook-5865F2)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Stable-success)

Automated update script for all running LXC containers in a Proxmox environment with logging and Discord notifications.

---

## 📌 Overview

This script:

- Iterates through all LXC containers (`pct list`)
- Detects container OS distribution
- Runs appropriate update commands:
  - Debian / Ubuntu / Kali → `apt`
  - Alpine → `apk`
- Logs results into a central log file
- Sends a summary report to Discord via webhook

### Tracks:

- ✅ Updated containers  
- ⏭️ Skipped containers  
- ❌ Failed updates  
- 🔁 Reboot-required containers  

---

## ⚙️ Features

- 🔍 Automatic distro detection (`/etc/os-release`)
- 📄 Centralized logging (`/var/log/update-all-lxc-pro.log`)
- 🔔 Discord webhook integration
- 🔁 Reboot detection (`/var/run/reboot-required`)
- 🧠 Smart skip logic (stopped containers / unsupported OS)
- 🧹 Cleanup included (`autoremove`, `autoclean`)

---

## 🏗️ Supported Distributions

| Distribution | Supported | Method |
|-------------|----------|--------|
| Debian      | ✅       | apt    |
| Ubuntu      | ✅       | apt    |
| Kali Linux  | ✅       | apt    |
| Alpine      | ✅       | apk    |
| Others      | ⏭️ Skipped | - |

## 📂 Script Location

```bash
/usr/local/bin/update-all-lxc-pro.sh
```

## 🧪 Usage

```bash
chmod +x /usr/local/bin/update-all-lxc-pro.sh
/usr/local/bin/update-all-lxc-pro.sh
```

## 📊 Example Output

```text
===== LXC update report - 2026-04-30 18:00:00 =====

----- Processing homebridge (201) -----
Detected distro: debian
UPDATED: homebridge (201)
REBOOT REQUIRED: homebridge (201)

----- Processing pihole (202) -----
Detected distro: debian
UPDATED: pihole (202)

----- Processing test-container (203) -----
SKIPPED: test-container (203) is not running

✅ LXC Update Finished
Updated: 2
Skipped: 1
Failed: 0
Reboot required: 1
Log: /var/log/update-all-lxc-pro.log
```

## 🔔 Discord Notifications

The script sends a summary message via webhook:

```bash
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/XXXX"
```

### Example message:

```text
✅ LXC Update Finished
Date: 2026-04-30 18:00:00
Updated: 5
Skipped: 2
Failed: 1
Reboot required: 3
Log: /var/log/update-all-lxc-pro.log
```

## 🛠️ Configuration

Edit the script variables:

```bash
LOG_FILE="/var/log/update-all-lxc-pro.log"
DISCORD_WEBHOOK_URL="your_webhook_url"
```

## ⚠️ Important Notes

- Script must be run on **Proxmox host**
- Requires:
  - `pct`
  - `curl`
- Containers must be **running**
- Some packages, for example **Homebridge**, may require manual updates. Consider using:

```bash
apt-mark hold homebridge
```

## 🔁 Optional: Cron Automation

Run daily at 3 AM:

```bash
crontab -e
0 3 * * * /usr/local/bin/update-all-lxc-pro.sh
```

## 🔒 Security Considerations

- Protect your Discord webhook URL
- Run script with appropriate privileges (root recommended)
- Logs may contain system information

---

## 🧠 Future Improvements (Ideas)

- 📦 Package exclusion list (e.g. homebridge)
- 🔄 Auto-reboot capability (optional flag)
- 📈 Prometheus/Grafana metrics export
- 📧 Email notifications fallback
- 🐳 Docker container support

---

## 📄 License

MIT License

---

## 🤝 Contributing

This project follows a **controlled appliance model**.  
Suggestions, issues, and discussions are welcome via **GitHub Issues**.

---

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/X8X31QYP4A)

