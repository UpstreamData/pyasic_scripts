#!/bin/bash

function update_cron_tune () {
      # Install python3-venv (for Ubuntu systems)
    if [[ -f /etc/lsb-release && $(grep "DISTRIB_ID=Ubuntu" /etc/lsb-release) ]]; then
        sudo apt-get update
        sudo apt-get install -y python3-venv
    fi

    # Download the Python file and requirements.txt from GitHub
    mkdir -p /opt/cron_tune
    sudo rm /opt/cron_tune/main.py
    sudo rm /opt/cron_tune/requirements.txt
    wget -O /tmp/main.py https://raw.githubusercontent.com/UpstreamData/pyasic_scripts/master/cron_tune/main.py
    wget -O /tmp/requirements.txt https://raw.githubusercontent.com/UpstreamData/pyasic_scripts/master/cron_tune/requirements.txt

    sudo mv /tmp/main.py /opt/cron_tune/main.py
    sudo mv /tmp/requirements.txt /opt/cron_tune/requirements.txt

    # Set up a virtual environment
    python3 -m venv /opt/cron_tune/venv
    source /opt/cron_tune/venv/bin/activate

    # Install required packages
    pip install -r /opt/cron_tune/requirements.txt
}
update_cron_tune