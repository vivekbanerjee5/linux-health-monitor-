
# Linux Server Health Monitoring Tool

A Bash-based Linux system monitoring tool that collects system health
metrics, identifies resource-intensive processes, generates reports,
and records threshold-based alerts.

## Features

- System uptime and hostname reporting
- One-minute CPU load and CPU core count
- Memory usage monitoring
- Root filesystem disk usage monitoring
- Top five CPU-consuming processes
- Top five memory-consuming processes
- Configurable warning and critical thresholds
- Timestamped health reports
- Separate alert history
- Exit codes for automation
- Cron-compatible execution

## Technologies

- Bash
- Linux command-line utilities
- awk
- ps
- free
- df
- uptime
- cron

## Requirements

- Linux or Ubuntu on WSL
- Bash
- procps utilities
- coreutils and awk

## Installation

Clone the repository:

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
cd linux-health-monitor
chmod +x server_health.sh
```

Replace `YOUR_GITHUB_REPOSITORY_URL` with your repository URL.

## Usage

Run a health check:

```bash
./server_health.sh
```

Check the report history:

```bash
tail -n 40 health.log
```

Check alert history:

```bash
tail -n 20 alerts.log
```

## Configuration

Edit the threshold variables near the top of `server_health.sh`.

| Setting | Default |
|---|---:|
| CPU load warning multiplier | 1 |
| Memory warning | 80% |
| Memory critical | 90% |
| Disk warning | 80% |
| Disk critical | 90% |

CPU load is compared with the number of available CPU cores.
Memory and disk usage are checked against their configured thresholds.

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | Healthy |
| 1 | Warning |
| 2 | Critical |

## Project Structure

```text
linux-health-monitor/
├── server_health.sh
├── README.md
├── .gitignore
└── screenshots/
```

The log files are generated when the script runs and are excluded
from version control.

## Limitations

- This is a lightweight monitoring script, not a replacement for
  a production monitoring platform.
- CPU load is not the same as instantaneous CPU utilization.
- Process CPU percentages can vary between snapshots.
- Email or external notifications are not currently configured.
- WSL results reflect the Linux environment visible to the script.

## Future Improvements

- Scheduled monitoring with cron
- Log rotation
- More detailed service checks
- Optional notification integrations

## Author

Student project focused on Linux administration, Bash scripting,
system troubleshooting, and cloud-support fundamentals.
