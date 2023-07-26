#!/bin/bash

# Initialize an array to store the cron jobs
cron_jobs=()

# Function to add a new cron job
function add_cron_job() {
    echo "Enter the hour of the day to run the script (in 24-hour format, e.g., 0-23):"
    read hour_of_day
    echo "Enter the IP address of the miner to set tuning (e.g. 192.168.1.20):"
    read ip_address
    echo "Enter the wattage to set on the miner (e.g. 2400):"
    read wattage
    cron_time="$hour_of_day * * *"
    cron_jobs+=("$cron_time /path/to/venv/bin/python /path/to/your_python_file.py $ip_address $wattage")
}

# Download the Python file and requirements.txt from GitHub
wget https://raw.githubusercontent.com/UpstreamData/pyasic_scripts/master/cron_tune/main.py
wget https://raw.githubusercontent.com/UpstreamData/pyasic_scripts/master/cron_tune/requirements.txt

# Set up a virtual environment
python3 -m venv venv
source venv/bin/activate

# Install required packages
pip install -r requirements.txt

# Loop to add cron jobs
while true; do
    add_cron_job

    while true; do
        echo "Do you want to add another cron job? (yes/no)"
        read add_another
        if [[ $add_another == "yes" || $add_another == "no" ]]; then
            break
        else
            echo "Invalid input. Please enter 'yes' or 'no'."
        fi
    done

    if [[ $add_another == "no" ]]; then
        break
    fi
done

# Add all the cron jobs to crontab
for cron_job in "${cron_jobs[@]}"; do
    (crontab -l ; echo "$cron_job") | crontab -
done
