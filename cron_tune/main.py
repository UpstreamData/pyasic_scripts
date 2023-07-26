import pyasic

import sys
import asyncio
import logging
import platform


log_file = '/opt/cron_tune/cron_tune.log'
if platform.system() == 'Windows':
    # If running on Windows, use a file in the current directory for logging
    log_file = 'cron_tune.log'

log_level = logging.INFO

logger = logging.getLogger()
logger.setLevel(log_level)
file_handler = logging.FileHandler(log_file)
log_format = '(%(asctime)s)[%(levelname)s] - %(message)s'
formatter = logging.Formatter(log_format)
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)


async def main():
    ip = sys.argv[1]
    wattage = sys.argv[2]

    logging.info(f"Setting tuning for miner:\n\t[IP] - {ip}\n\t[Wattage] - {wattage}")

    miner = await pyasic.get_miner(ip)

    if miner is None:
        logging.critical(f"Could not identify miner:\n\t[IP] - {ip}")
        logging.info(f"Stopping.")
        exit(-1)

    logging.info(f"Found miner type: {miner}")

    if not miner.supports_autotuning:
        logging.error(f"Miner type does not support setting power limit: {miner}")
        logging.info(f"Stopping.")
        exit(-1)

    logging.info(f"Pushing power limit update: {wattage}W")

    await miner.set_power_limit(int(wattage))

    logging.info(f"Done. Miner should now be set to {wattage}W")


asyncio.run(main())
