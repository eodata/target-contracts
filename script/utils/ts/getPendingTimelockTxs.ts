import { ethers } from 'ethers';
import EthDater from 'ethereum-block-by-date';
import fs from 'fs';
import dotenv from 'dotenv';

dotenv.config();

export class TimelockTxs {
    private timelockContract: ethers.Contract;
    private signer: ethers.Signer;
    private readonly CONFIG_PATH = 'script/sourcesAndFeeds/ovsConfig.json';

    constructor(signer: ethers.Signer, chainId: number, eoracleChainId: number) {
        const configAddress = JSON.parse(fs.readFileSync(`script/config/${chainId}/${eoracleChainId}/targetContractAddresses.json`, 'utf-8')).timelock;
        const timelockAbi = `[
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": true,
                        "name": "id",
                        "type": "bytes32"
                    }
                ],
                "name": "Cancelled",
                "type": "event"
            },
            {
                "anonymous": false,
                "inputs": [
                {
                    "indexed": true,
                    "name": "id",
                    "type": "bytes32"
                },
                {
                    "indexed": true,
                    "name": "index",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "name": "target",
                    "type": "address"
                },
                {
                    "indexed": false,
                    "name": "value",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "name": "data",
                    "type": "bytes"
                },
                {
                    "indexed": false,
                    "name": "predecessor",
                    "type": "bytes32"
                },
                {
                    "indexed": false,
                    "name": "delay",
                    "type": "uint256"
                }
                ],
                "name": "CallScheduled",
                "type": "event"
            },
            {
                "anonymous": false,
                "inputs": [
                {
                    "indexed": true,
                    "name": "id",
                    "type": "bytes32"
                },
                {
                    "indexed": true,
                    "name": "index",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "name": "target",
                    "type": "address"
                },
                {
                    "indexed": false,
                    "name": "value",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "name": "data",
                    "type": "bytes"
                }
                ],
                "name": "CallExecuted",
                "type": "event"
            }
            ]`
        this.timelockContract = new ethers.Contract(configAddress, timelockAbi, signer);
        this.signer = signer;
    }

    public async execute() {
        const dater = new EthDater(
            this.signer.provider
        );
        let block = await dater.getDate('2024-01-01T13:20:40Z');
        const fromBlock = block.block;
        const toBlock = 'latest';
        // Get all CallScheduled events
        const scheduledFilter = this.timelockContract.filters.CallScheduled();
        let scheduledEvents = await this.timelockContract.queryFilter(scheduledFilter, fromBlock, toBlock);

        // Get all CallExecuted events
        const executedFilter = this.timelockContract.filters.CallExecuted();
        let executedEvents = await this.timelockContract.queryFilter(executedFilter, fromBlock, toBlock);

        // Get all Cancelled events
        const cancelledFilter = this.timelockContract.filters.Cancelled();
        let cancelledEvents = await this.timelockContract.queryFilter(cancelledFilter, fromBlock, toBlock);

        // Filter out cancelled and executed events
        scheduledEvents = scheduledEvents.filter(event => 
            !cancelledEvents.some(cancelledEvent => (cancelledEvent as ethers.EventLog).args.id === (event as ethers.EventLog).args.id) &&
            !executedEvents.some(executedEvent => (executedEvent as ethers.EventLog).args.id === (event as ethers.EventLog).args.id)
        );
        const scheduledIds = scheduledEvents.map(event => {
            return {
                id: (event as ethers.EventLog).args.id,
                target: (event as ethers.EventLog).args.target,
                data: (event as ethers.EventLog).args.data,
            }
        });

        console.log("scheduledEvents", scheduledIds);

    }
}

async function getChainId(signer: ethers.Signer) {
    return await signer.provider?.getNetwork().then(network => network.chainId);
}
async function main() {
    const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
    const eoracleChainId = Number(process.env.EORACLE_CHAIN_ID);
    const signer = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
    const chainId: number = Number(await getChainId(signer));
    const timelockTxs = new TimelockTxs(signer, chainId, eoracleChainId);
    await timelockTxs.execute();
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
}); 
