#!/bin/bash

############################################################################################################################################################
# RUN WITH                                                                                                                                                 #
# curl -sSL https://raw.githubusercontent.com/UpstreamData/pyasic_scripts/master/cron_tune/install.sh -o install.sh && chmod +x install.sh && ./install.sh #
############################################################################################################################################################


# Function to validate the IP address format
function validate_ip() {
    local ip=$1
    local valid_ip_regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
    if [[ ! $ip =~ $valid_ip_regex ]]; then
        echo "Invalid IP address format. Please try again."
        return 1
    fi
}

# Function to validate the hour of the day
function validate_hour() {
    local hour=$1
    if ! [[ $hour =~ ^[0-9]+$ ]]; then
        echo "Invalid hour format. Please enter a number between 0 and 23."
        return 1
    fi

    if ((hour < 0 || hour > 23)); then
        echo "Invalid hour. Please enter a number between 0 and 23."
        return 1
    fi
}

# Function to validate the wattage
function validate_wattage() {
    local wattage=$1
    if ! [[ $wattage =~ ^[0-9]+$ ]]; then
        echo "Invalid wattage. Please enter a valid number."
        return 1
    fi
}

# Function to set up everything
function setup_cron_jobs() {
    # Install python3-venv (for Ubuntu systems)
    if [[ -f /etc/lsb-release && $(grep "DISTRIB_ID=Ubuntu" /etc/lsb-release) ]]; then
        sudo apt-get update
        sudo apt-get install -y python3-venv
    fi

    # Download the Python file and requirements.txt from GitHub
    mkdir -p /opt/cron_tune
    wget -O /opt/cron_tune/main.py https://raw.githubusercontent.com/UpstreamData/pyasic_scripts/master/cron_tune/main.py
    wget -O /opt/cron_tune/requirements.txt https://raw.githubusercontent.com/UpstreamData/pyasic_scripts/master/cron_tune/requirements.txt

    # Set up a virtual environment
    python3 -m venv /opt/cron_tune/venv
    source /opt/cron_tune/venv/bin/activate

    # Install required packages
    pip install -r /opt/cron_tune/requirements.txt

    # Loop to add cron jobs
    while true; do
        echo "Enter the hour of the day to run the script (in 24-hour format, e.g., 0-23):"
        read hour_of_day
        validate_hour "$hour_of_day" || continue

        echo "Enter the IP address of the miner to set tuning (e.g. 192.168.1.20):"
        read ip_address
        validate_ip "$ip_address" || continue

        echo "Enter the wattage to set on the miner (e.g. 2400):"
        read wattage
        validate_wattage "$wattage" || continue

        # Get the path to the virtual environment's Python interpreter
        venv_python_path=$(which python)

        cron_time="$hour_of_day * * *"
        cron_job="$cron_time $venv_python_path /opt/cron_tune/main.py $ip_address $wattage"

        echo "$cron_job" | sudo tee -a /etc/crontab

        echo "Cron job added for $hour_of_day:00 to run your Python script with IP: $ip_address and Wattage: $wattage."

        echo "Do you want to add another cron job? (yes/no)"
        read add_another
        if [[ $add_another != "yes" ]]; then
            break
        fi
    done
}

# Call the setup function
setup_cron_jobs