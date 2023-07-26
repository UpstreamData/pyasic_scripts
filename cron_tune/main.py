import pyasic
import sys
import asyncio


async def main():
    ip = sys.argv[1]
    wattage = sys.argv[2]

    miner = await pyasic.get_miner(ip)
    await miner.set_power_limit(int(wattage))


asyncio.run(main())
