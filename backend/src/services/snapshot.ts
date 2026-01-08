/**
 * Snapshot Service
 *
 * Captures Spirit token holder balances at a specific block.
 * Used to generate merkle trees for airstream claims.
 */

import { createPublicClient, http, parseAbi, formatUnits } from 'viem';
import { baseSepolia } from 'viem/chains';
import { config } from '../config.js';
import type { Snapshot, Holder, SnapshotWithHolders } from '../types/index.js';
import { generateId } from '../utils/id.js';

// ERC20 ABI for balance queries
const ERC20_ABI = parseAbi([
  'function balanceOf(address owner) view returns (uint256)',
  'function totalSupply() view returns (uint256)',
  'event Transfer(address indexed from, address indexed to, uint256 value)',
]);

// In-memory storage for development (use PostgreSQL in production)
const snapshots: Map<string, SnapshotWithHolders> = new Map();

export class SnapshotService {
  private client;
  private spiritTokenAddress: `0x${string}`;

  constructor() {
    this.client = createPublicClient({
      chain: baseSepolia,
      transport: http(config.blockchain.rpcUrl),
    });
    this.spiritTokenAddress = config.blockchain.spiritTokenAddress as `0x${string}`;
  }

  /**
   * Take a snapshot of Spirit token holders at the current block.
   *
   * In production, this would query The Graph or an indexer.
   * For MVP, we query Transfer events and compute balances.
   */
  async takeSnapshot(): Promise<Snapshot> {
    const blockNumber = await this.client.getBlockNumber();
    const block = await this.client.getBlock({ blockNumber });

    // Get holders by processing Transfer events
    const holders = await this.getHoldersFromEvents(blockNumber);

    const totalSupplyHeld = holders.reduce(
      (sum, h) => sum + h.balance,
      BigInt(0)
    );

    const snapshot: SnapshotWithHolders = {
      id: generateId('snap'),
      blockNumber: Number(blockNumber),
      timestamp: Number(block.timestamp),
      totalHolders: holders.length,
      totalSupplyHeld,
      chainId: config.blockchain.chainId,
      holders,
    };

    // Store snapshot
    snapshots.set(snapshot.id, snapshot);

    return {
      id: snapshot.id,
      blockNumber: snapshot.blockNumber,
      timestamp: snapshot.timestamp,
      totalHolders: snapshot.totalHolders,
      totalSupplyHeld: snapshot.totalSupplyHeld,
      chainId: snapshot.chainId,
    };
  }

  /**
   * Get snapshot by ID.
   */
  async getSnapshot(id: string): Promise<Snapshot | null> {
    const snapshot = snapshots.get(id);
    if (!snapshot) return null;

    return {
      id: snapshot.id,
      blockNumber: snapshot.blockNumber,
      timestamp: snapshot.timestamp,
      totalHolders: snapshot.totalHolders,
      totalSupplyHeld: snapshot.totalSupplyHeld,
      chainId: snapshot.chainId,
    };
  }

  /**
   * Get holders from a snapshot.
   */
  async getHolders(snapshotId: string): Promise<Holder[]> {
    const snapshot = snapshots.get(snapshotId);
    if (!snapshot) {
      throw new Error(`Snapshot not found: ${snapshotId}`);
    }
    return snapshot.holders;
  }

  /**
   * Get holders by processing Transfer events.
   *
   * NOTE: This is a simplified implementation for MVP.
   * In production, use The Graph subgraph for efficient queries.
   */
  private async getHoldersFromEvents(toBlock: bigint): Promise<Holder[]> {
    // Get total supply for percentage calculation
    const totalSupply = await this.client.readContract({
      address: this.spiritTokenAddress,
      abi: ERC20_ABI,
      functionName: 'totalSupply',
    }) as bigint;

    // RPC providers limit block range (typically 100K blocks)
    // For MVP, we'll query recent blocks only
    // In production, use The Graph subgraph for full history
    const MAX_BLOCK_RANGE = BigInt(50000);
    const fromBlock = toBlock > MAX_BLOCK_RANGE ? toBlock - MAX_BLOCK_RANGE : BigInt(0);

    // Fetch Transfer events from recent blocks
    const logs = await this.client.getLogs({
      address: this.spiritTokenAddress,
      event: {
        type: 'event',
        name: 'Transfer',
        inputs: [
          { type: 'address', indexed: true, name: 'from' },
          { type: 'address', indexed: true, name: 'to' },
          { type: 'uint256', indexed: false, name: 'value' },
        ],
      },
      fromBlock,
      toBlock,
    });

    // Build balance map
    const balances = new Map<string, bigint>();
    const zeroAddress = '0x0000000000000000000000000000000000000000';

    for (const log of logs) {
      const from = log.args.from?.toLowerCase();
      const to = log.args.to?.toLowerCase();
      const value = log.args.value || BigInt(0);

      if (from && from !== zeroAddress) {
        const currentFrom = balances.get(from) || BigInt(0);
        balances.set(from, currentFrom - value);
      }

      if (to && to !== zeroAddress) {
        const currentTo = balances.get(to) || BigInt(0);
        balances.set(to, currentTo + value);
      }
    }

    // Convert to Holder array (filter out zero balances)
    const holders: Holder[] = [];
    for (const [address, balance] of balances) {
      if (balance > BigInt(0)) {
        holders.push({
          address,
          balance,
          percentOfSupply: Number(balance * BigInt(10000) / totalSupply) / 100,
        });
      }
    }

    // Sort by balance descending
    holders.sort((a, b) => (b.balance > a.balance ? 1 : -1));

    return holders;
  }

  /**
   * Verify an address was in a snapshot with a specific balance.
   */
  async verifyHolder(
    snapshotId: string,
    address: string,
    expectedBalance: bigint
  ): Promise<boolean> {
    const holders = await this.getHolders(snapshotId);
    const holder = holders.find(
      h => h.address.toLowerCase() === address.toLowerCase()
    );
    return holder?.balance === expectedBalance;
  }
}

// Singleton instance
export const snapshotService = new SnapshotService();
