#!/bin/bash

# Initialize an array to store the cron jobs
cron_jobs=()

# Function to add a new cron job
function add_cron_job() {
    echo "Enter the hour of the day to run the script (in 24-hour format, e.g., 0-23):"
    read hour_of_day
    echo "Enter the IP address:"
    read ip_address
    echo "Enter the wattage:"
    read wattage
    cron_time="$hour_of_day * * *"
    cron_jobs+=("$cron_time /path/to/venv/bin/python /path/to/your_python_file.py $ip_address $wattage")
}

# Download the Python file and requirements.txt from GitHub
wget https://raw.githubusercontent.com/yourusername/yourrepository/main/your_python_file.py
wget https://raw.githubusercontent.com/yourusername/yourrepository/main/requirements.txt

# Set up a virtual environment
python3 -m venv venv
source venv/bin/activate

# Install required packages
pip install -r requirements.txt

# Loop to add cron jobs
while true; do
    add_cron_job

    echo "Do you want to add another cron job? (yes/no)"
    read add_another
    if [[ $add_another != "yes" ]]; then
        break
    fi
done

# Add all the cron jobs to crontab
for cron_job in "${cron_jobs[@]}"; do
    (crontab -l ; echo "$cron_job") | crontab -
done
