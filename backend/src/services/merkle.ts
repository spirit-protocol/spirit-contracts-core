/**
 * Merkle Service
 *
 * Generates merkle trees from snapshots for airstream claims.
 * Uses OpenZeppelin's merkle-tree library for compatibility with Solidity.
 */

import { StandardMerkleTree } from '@openzeppelin/merkle-tree';
import { keccak256, encodePacked } from 'viem';
import { snapshotService } from './snapshot.js';
import { ipfsService } from './ipfs.js';
import { generateId } from '../utils/id.js';
import { config } from '../config.js';
import type { MerkleTree, MerkleProof, Holder, MerkleLeaf } from '../types/index.js';

// In-memory storage for development (use PostgreSQL + IPFS in production)
const merkleTrees: Map<string, {
  tree: StandardMerkleTree<[string, string]>;
  metadata: MerkleTree;
}> = new Map();

export class MerkleService {
  /**
   * Generate a merkle tree from a snapshot.
   *
   * Leaf format: [address, amount]
   * The leaf is hashed as: keccak256(abi.encodePacked(address, amount))
   */
  async generateTree(snapshotId: string): Promise<MerkleTree> {
    // Get holders from snapshot
    const holders = await snapshotService.getHolders(snapshotId);

    // Handle empty snapshot (testnet or fresh deployment)
    if (holders.length === 0) {
      console.warn('Empty snapshot - creating placeholder merkle tree');
      // Create a tree with a placeholder entry (protocol treasury as sole holder)
      // This allows testing without real token holders
      const placeholderLeaf: [string, string] = [
        '0x0000000000000000000000000000000000000001', // Placeholder address
        '0', // Zero allocation
      ];
      const tree = StandardMerkleTree.of([placeholderLeaf], ['address', 'uint256']);

      const treeId = generateId('tree');
      const metadata: MerkleTree = {
        id: treeId,
        snapshotId,
        root: tree.root,
        leafCount: 0, // Actual holder count is 0
        createdAt: Math.floor(Date.now() / 1000),
      };

      merkleTrees.set(treeId, { tree, metadata });
      return metadata;
    }

    // Convert holders to merkle leaves
    // Format: [address, amount as string] for StandardMerkleTree
    const leaves: [string, string][] = holders.map(holder => [
      holder.address,
      holder.balance.toString(),
    ]);

    // Generate tree using OpenZeppelin's library
    // This ensures compatibility with Solidity's MerkleProof.verify
    const tree = StandardMerkleTree.of(leaves, ['address', 'uint256']);

    const treeId = generateId('tree');
    const metadata: MerkleTree = {
      id: treeId,
      snapshotId,
      root: tree.root,
      leafCount: holders.length,
      createdAt: Math.floor(Date.now() / 1000),
    };

    // Store tree
    merkleTrees.set(treeId, { tree, metadata });

    // Upload to IPFS if configured
    if (ipfsService.isConfigured()) {
      try {
        const treeJson = JSON.stringify(tree.dump());
        const ipfsResult = await ipfsService.uploadMerkleTree(
          treeId,
          treeJson,
          {
            snapshotId,
            root: tree.root,
            leafCount: holders.length,
            chainId: config.blockchain.chainId,
          }
        );
        metadata.ipfsHash = ipfsResult.hash;
        console.log(`Merkle tree uploaded to IPFS: ${ipfsResult.url}`);
      } catch (error) {
        console.error('Failed to upload merkle tree to IPFS:', error);
        // Continue without IPFS - tree is still stored locally
      }
    }

    return metadata;
  }

  /**
   * Get merkle proof for a specific address.
   */
  async getProof(treeId: string, address: string): Promise<MerkleProof> {
    const stored = merkleTrees.get(treeId);
    if (!stored) {
      throw new Error(`Merkle tree not found: ${treeId}`);
    }

    const { tree } = stored;
    const normalizedAddress = address.toLowerCase();

    // Find the leaf for this address
    for (const [i, [leafAddress, leafAmount]] of tree.entries()) {
      if (leafAddress.toLowerCase() === normalizedAddress) {
        const proof = tree.getProof(i);
        return {
          address: leafAddress,
          amount: BigInt(leafAmount),
          proof,
        };
      }
    }

    throw new Error(`Address not found in tree: ${address}`);
  }

  /**
   * Verify a proof against a root.
   */
  verifyProof(
    root: string,
    proof: string[],
    address: string,
    amount: bigint
  ): boolean {
    // Recreate the leaf
    const leaf = this.hashLeaf(address, amount);

    // Verify by recomputing root
    let computedHash = leaf;
    for (const proofElement of proof) {
      if (computedHash < proofElement) {
        computedHash = keccak256(
          encodePacked(['bytes32', 'bytes32'], [computedHash as `0x${string}`, proofElement as `0x${string}`])
        );
      } else {
        computedHash = keccak256(
          encodePacked(['bytes32', 'bytes32'], [proofElement as `0x${string}`, computedHash as `0x${string}`])
        );
      }
    }

    return computedHash === root;
  }

  /**
   * Get tree metadata by ID.
   */
  async getTree(treeId: string): Promise<MerkleTree | null> {
    const stored = merkleTrees.get(treeId);
    return stored?.metadata ?? null;
  }

  /**
   * Get all leaves (for IPFS storage).
   */
  async getLeaves(treeId: string): Promise<MerkleLeaf[]> {
    const stored = merkleTrees.get(treeId);
    if (!stored) {
      throw new Error(`Merkle tree not found: ${treeId}`);
    }

    const leaves: MerkleLeaf[] = [];
    for (const [, [address, amount]] of stored.tree.entries()) {
      leaves.push({
        address,
        amount: BigInt(amount),
      });
    }
    return leaves;
  }

  /**
   * Export tree to JSON (for IPFS upload).
   */
  async exportTree(treeId: string): Promise<string> {
    const stored = merkleTrees.get(treeId);
    if (!stored) {
      throw new Error(`Merkle tree not found: ${treeId}`);
    }

    // StandardMerkleTree.dump() returns a JSON-serializable object
    const dump = stored.tree.dump();
    return JSON.stringify(dump);
  }

  /**
   * Import tree from JSON (for loading from IPFS).
   */
  async importTree(json: string, metadata: MerkleTree): Promise<void> {
    const dump = JSON.parse(json);
    const tree = StandardMerkleTree.load(dump) as StandardMerkleTree<[string, string]>;

    merkleTrees.set(metadata.id, { tree, metadata });
  }

  /**
   * Hash a leaf in the same way as the contract.
   */
  private hashLeaf(address: string, amount: bigint): string {
    return keccak256(
      encodePacked(['address', 'uint256'], [address as `0x${string}`, amount])
    );
  }

  /**
   * Calculate airstream amounts based on snapshot.
   *
   * Each holder receives: (their_balance / total_held) * total_airdrop
   */
  calculateAirstreamAmounts(
    holders: Holder[],
    totalAirdrop: bigint
  ): Map<string, bigint> {
    const totalHeld = holders.reduce((sum, h) => sum + h.balance, BigInt(0));
    const amounts = new Map<string, bigint>();

    for (const holder of holders) {
      // Pro-rata allocation
      const amount = (holder.balance * totalAirdrop) / totalHeld;
      if (amount > BigInt(0)) {
        amounts.set(holder.address, amount);
      }
    }

    return amounts;
  }
}

// Singleton instance
export const merkleService = new MerkleService();
