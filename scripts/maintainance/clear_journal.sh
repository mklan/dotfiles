# Check journal size
journalctl --disk-usage

# Clean logs older than 7 days
sudo journalctl --vacuum-time=7d

# Alternatively, limit journal size
sudo journalctl --vacuum-size=200M
