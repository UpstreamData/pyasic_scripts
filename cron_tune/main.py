import pyasic

import sys
import asyncio
import logging
import platform

RETRIES = 3

log_file = "/opt/cron_tune/cron_tune.log"
if platform.system() == "Windows":
    # If running on Windows, use a file in the current directory for logging
    log_file = "cron_tune.log"

log_level = logging.INFO

logger = logging.getLogger()
logger.setLevel(log_level)
file_handler = logging.FileHandler(log_file)
log_format = "(%(asctime)s)[%(levelname)s] - %(message)s"
formatter = logging.Formatter(log_format)
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)


async def main():
    ip = sys.argv[1]
    wattage_shutdown = sys.argv[2]
    if str(wattage_shutdown) in ["on", "off"]:
        await set_shutdown(ip, wattage_shutdown)
    else:
        await set_tuning(ip, int(wattage_shutdown))


async def set_shutdown(ip: str, mode: str):
    logging.info(
        f"Setting shutdown mode for miner:\n\t[IP] - {ip}\n\t[Mode] - {'Enabled' if mode == 'on' else 'Disabled'}"
    )

    miner = await identify_miner(ip)

    if not miner.supports_shutdown:
        logging.error(f"Miner type does not support shutdown mode: {miner}")
        logging.info(f"Stopping.")
        exit(-1)

    logging.info(f"Pushing shutdown mode update.")

    for i in range(RETRIES):
        if mode == "on":
            result = await miner.resume_mining()
        else:
            result = await miner.stop_mining()

        if result is not False:
            break

        logging.error(
            f"Set shutdown mode (Attempt {i + 1}) failed on miner:\n\t[IP] - {ip}\n\t[Mode] - {'Enabled' if mode == 'on' else 'Disabled'}"
        )
        if i + 1 == RETRIES:
            logging.critical(
                f"Set shutdown mode failed after {RETRIES} retries, exiting."
            )
            exit(-1)

    logging.info(
        f"Done. Miner should now be {'enabled' if mode == 'on' else 'disabled'}."
    )


async def set_tuning(ip: str, wattage: int):
    logging.info(f"Setting tuning for miner:\n\t[IP] - {ip}\n\t[Wattage] - {wattage}")

    miner = await identify_miner(ip)

    if not miner.supports_autotuning:
        logging.error(f"Miner type does not support setting power limit: {miner}")
        logging.info(f"Stopping.")
        exit(-1)

    logging.info(f"Pushing power limit update: {wattage}W")

    for i in range(RETRIES):
        result = await miner.set_power_limit(int(wattage))

        if result is not False:
            break

        logging.error(
            f"Apply power limit (Attempt {i + 1}) failed on miner:\n\t[IP] - {ip}\n\t[Wattage] - {wattage}"
        )
        if i + 1 == RETRIES:
            logging.critical(
                f"Apply power limit failed after {RETRIES} retries, exiting."
            )
            exit(-1)

    logging.info(f"Done. Miner should now be set to {wattage}W")


async def identify_miner(ip: str):
    miner = await pyasic.get_miner(ip)

    if miner is None:
        logging.critical(f"Could not identify miner:\n\t[IP] - {ip}")
        logging.info(f"Stopping.")
        exit(-1)

    logging.info(f"Found miner type: {miner}")
    return miner


asyncio.run(main())
