# pyasic Scripts

### cron_tune
cron_tune is a script that sets the wattage of your miner using `cron` on an external device.  You tell it the IP of the miner, the hour of the day, and the wattage to set.

Run it automatically on Linux based systems with -

`curl -sSL https://raw.githubusercontent.com/UpstreamData/pyasic_scripts/master/cron_tune/install.sh -o install.sh && chmod +x install.sh && sudo ./install.sh`

This script installs the cron jobs to `/etc/crontab`, and the python scripts to run to `/opt/cron_tune`.

Logs are located at `/opt/cron_tune/cron_tune.log`, and can be read with `tail /opt/cron_tune/cron_tune.log` 

### updating
To update from old versions of `cron_tune`, you can run the update.sh script.

`curl -sSL https://raw.githubusercontent.com/UpstreamData/pyasic_scripts/master/cron_tune/update.sh -o update.sh && chmod +x update.sh && sudo ./update.sh`
