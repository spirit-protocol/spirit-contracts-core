/**
 * Contract Service
 *
 * Handles all interactions with Spirit Protocol smart contracts.
 * Uses viem for type-safe contract calls.
 */

import {
  createPublicClient,
  createWalletClient,
  http,
  parseAbi,
  type Address,
  type Hash,
  type WalletClient,
} from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { baseSepolia } from 'viem/chains';
import { config } from '../config.js';

// SpiritFactory ABI - only the functions we need
const SPIRIT_FACTORY_ABI = parseAbi([
  // createChild without specialAllocation (simpler version)
  'function createChild(string name, string symbol, address artist, address agent, bytes32 merkleRoot, uint160 initialSqrtPriceX96) external returns (address child, address stakingPool)',
  // createChild with specialAllocation
  'function createChild(string name, string symbol, address artist, address agent, uint256 specialAllocation, bytes32 merkleRoot, uint160 initialSqrtPriceX96) external returns (address child, address stakingPool)',
  // View functions
  'function SPIRIT() external view returns (address)',
  'function CHILD_TOTAL_SUPPLY() external view returns (uint256)',
  'function DEFAULT_LIQUIDITY_SUPPLY() external view returns (uint256)',
  'function AIRSTREAM_SUPPLY() external view returns (uint96)',
  'function hasRole(bytes32 role, address account) external view returns (bool)',
  'function DEFAULT_ADMIN_ROLE() external view returns (bytes32)',
  // Events
  'event ChildTokenCreated(address indexed child, address indexed stakingPool, address artist, address agent, bytes32 merkleRoot)',
]);

export interface CreateChildParams {
  name: string;
  symbol: string;
  artist: Address;
  agent: Address;
  merkleRoot: `0x${string}`;
  sqrtPriceX96: bigint;
  specialAllocation?: bigint;
}

export interface CreateChildResult {
  childToken: Address;
  stakingPool: Address;
  transactionHash: Hash;
}

export class ContractService {
  private publicClient;
  private walletClient: WalletClient | null = null;
  private factoryAddress: Address;
  private initialized = false;

  constructor() {
    this.publicClient = createPublicClient({
      chain: baseSepolia,
      transport: http(config.blockchain.rpcUrl),
    });
    this.factoryAddress = config.blockchain.spiritFactoryAddress as Address;
  }

  /**
   * Initialize wallet client with admin private key.
   * Call this before making write transactions.
   */
  async initialize(): Promise<void> {
    if (this.initialized) return;

    const privateKey = config.blockchain.adminPrivateKey;
    if (!privateKey) {
      console.warn('No admin private key configured - contract writes will fail');
      return;
    }

    try {
      const account = privateKeyToAccount(privateKey as `0x${string}`);
      this.walletClient = createWalletClient({
        account,
        chain: baseSepolia,
        transport: http(config.blockchain.rpcUrl),
      });

      // Verify admin role
      const hasAdmin = await this.checkAdminRole(account.address);
      if (!hasAdmin) {
        console.warn(`Address ${account.address} does not have admin role on factory`);
      } else {
        console.log(`Contract service initialized with admin: ${account.address}`);
      }

      this.initialized = true;
    } catch (error) {
      console.error('Failed to initialize contract service:', error);
      throw error;
    }
  }

  /**
   * Check if an address has admin role on the factory.
   */
  async checkAdminRole(address: Address): Promise<boolean> {
    try {
      const adminRole = await this.publicClient.readContract({
        address: this.factoryAddress,
        abi: SPIRIT_FACTORY_ABI,
        functionName: 'DEFAULT_ADMIN_ROLE',
      }) as `0x${string}`;

      const hasRole = await this.publicClient.readContract({
        address: this.factoryAddress,
        abi: SPIRIT_FACTORY_ABI,
        functionName: 'hasRole',
        args: [adminRole, address],
      }) as boolean;

      return hasRole;
    } catch (error) {
      console.error('Failed to check admin role:', error);
      return false;
    }
  }

  /**
   * Create a new child token via SpiritFactory.
   */
  async createChild(params: CreateChildParams): Promise<CreateChildResult> {
    if (!this.walletClient) {
      throw new Error('Contract service not initialized - call initialize() first');
    }

    const { name, symbol, artist, agent, merkleRoot, sqrtPriceX96, specialAllocation } = params;

    console.log(`Creating child token: ${symbol}`);
    console.log(`  Artist: ${artist}`);
    console.log(`  Agent: ${agent}`);
    console.log(`  Merkle Root: ${merkleRoot}`);
    console.log(`  sqrtPriceX96: ${sqrtPriceX96}`);

    try {
      // Simulate first to catch errors
      let simulationResult;

      if (specialAllocation !== undefined) {
        // Use version with special allocation
        simulationResult = await this.publicClient.simulateContract({
          address: this.factoryAddress,
          abi: SPIRIT_FACTORY_ABI,
          functionName: 'createChild',
          args: [name, symbol, artist, agent, specialAllocation, merkleRoot, sqrtPriceX96],
          account: this.walletClient.account,
        });
      } else {
        // Use simpler version without special allocation
        simulationResult = await this.publicClient.simulateContract({
          address: this.factoryAddress,
          abi: SPIRIT_FACTORY_ABI,
          functionName: 'createChild',
          args: [name, symbol, artist, agent, merkleRoot, sqrtPriceX96],
          account: this.walletClient.account,
        });
      }

      console.log('Simulation successful, submitting transaction...');

      // Execute the transaction
      const hash = await this.walletClient.writeContract(simulationResult.request as any);

      console.log(`Transaction submitted: ${hash}`);

      // Wait for confirmation
      const receipt = await this.publicClient.waitForTransactionReceipt({
        hash,
        confirmations: 1,
      });

      if (receipt.status !== 'success') {
        throw new Error(`Transaction failed: ${hash}`);
      }

      // Parse logs to get child and stakingPool addresses
      const childCreatedLog = receipt.logs.find(log => {
        // ChildTokenCreated event topic
        return log.topics[0] === '0x' + 'ChildTokenCreated'.padEnd(64, '0'); // Simplified
      });

      // For now, extract from simulation result
      const [childToken, stakingPool] = simulationResult.result as [Address, Address];

      console.log(`Child token created: ${childToken}`);
      console.log(`Staking pool created: ${stakingPool}`);

      return {
        childToken,
        stakingPool,
        transactionHash: hash,
      };
    } catch (error) {
      console.error('Failed to create child token:', error);
      throw error;
    }
  }

  /**
   * Get factory constants for validation.
   */
  async getFactoryConstants(): Promise<{
    childTotalSupply: bigint;
    liquiditySupply: bigint;
    airstreamSupply: bigint;
    spiritToken: Address;
  }> {
    const [childTotalSupply, liquiditySupply, airstreamSupply, spiritToken] = await Promise.all([
      this.publicClient.readContract({
        address: this.factoryAddress,
        abi: SPIRIT_FACTORY_ABI,
        functionName: 'CHILD_TOTAL_SUPPLY',
      }) as Promise<bigint>,
      this.publicClient.readContract({
        address: this.factoryAddress,
        abi: SPIRIT_FACTORY_ABI,
        functionName: 'DEFAULT_LIQUIDITY_SUPPLY',
      }) as Promise<bigint>,
      this.publicClient.readContract({
        address: this.factoryAddress,
        abi: SPIRIT_FACTORY_ABI,
        functionName: 'AIRSTREAM_SUPPLY',
      }) as Promise<bigint>,
      this.publicClient.readContract({
        address: this.factoryAddress,
        abi: SPIRIT_FACTORY_ABI,
        functionName: 'SPIRIT',
      }) as Promise<Address>,
    ]);

    return {
      childTotalSupply,
      liquiditySupply,
      airstreamSupply,
      spiritToken,
    };
  }

  /**
   * Check if service is ready for write operations.
   */
  isReady(): boolean {
    return this.initialized && this.walletClient !== null;
  }

  /**
   * Get the admin address (if initialized).
   */
  getAdminAddress(): Address | null {
    return this.walletClient?.account?.address ?? null;
  }
}

// Singleton instance
export const contractService = new ContractService();
