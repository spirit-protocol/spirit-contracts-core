/**
 * Spirit Protocol Backend Types
 * Canonical types for self-service API
 */

// ============================================
// Snapshot Types
// ============================================

export interface Snapshot {
  id: string;
  blockNumber: number;
  timestamp: number;
  totalHolders: number;
  totalSupplyHeld: bigint;
  chainId: number;
}

export interface Holder {
  address: string;
  balance: bigint;
  percentOfSupply: number;
}

export interface SnapshotWithHolders extends Snapshot {
  holders: Holder[];
}

// ============================================
// Merkle Types
// ============================================

export interface MerkleTree {
  id: string;
  snapshotId: string;
  root: string;
  leafCount: number;
  ipfsHash?: string;
  createdAt: number;
}

export interface MerkleProof {
  address: string;
  amount: bigint;
  proof: string[];
}

export interface MerkleLeaf {
  address: string;
  amount: bigint;
}

// ============================================
// Price Types
// ============================================

export interface PriceData {
  spiritPriceUsd: number;
  spiritFdv: bigint;
  source: 'coingecko' | 'dexscreener' | 'onchain' | 'manual';
  timestamp: number;
}

export interface SqrtPriceResult {
  sqrtPriceX96: bigint;
  priceRatio: number;
  spiritFdv: bigint;
  childFdv: bigint;
}

// ============================================
// Agent Creation Types
// ============================================

export interface CreateAgentRequest {
  name: string;
  symbol: string;
  artist: string;      // Creator wallet address
  agent: string;       // Agent wallet address
  platform: string;    // Platform address (Eden initially)
  metadataUri?: string;
}

export interface CreateAgentResponse {
  success: boolean;
  childToken: string;
  stakingPool: string;
  lpPosition?: string;
  merkleRoot: string;
  merkleTreeIpfs: string;
  transactionHash: string;
  snapshotId: string;
  blockNumber: number;
}

// ============================================
// Validation Types
// ============================================

export interface ValidationRules {
  // Rate limiting
  maxCreationsPerDay: number;
  maxCreationsPerAddress: number;

  // Parameter validation
  nameMinLength: number;
  nameMaxLength: number;
  symbolMinLength: number;
  symbolMaxLength: number;

  // Platform rules
  approvedPlatforms: string[];
  requirePlatformApproval: boolean;

  // Anti-spam
  minimumSpiritHeld: bigint;
  x402PaymentRequired: boolean;
}

export interface ValidationResult {
  valid: boolean;
  errors: string[];
}

// ============================================
// x402 Types
// ============================================

export interface X402PaymentProof {
  streamId: string;
  sender: string;
  flowRate: bigint;
  startTime: number;
  signature: string;
}

export interface X402Config {
  superfluidHost: string;
  acceptedToken: string;      // Token address for payment
  minimumFlowRate: bigint;    // Minimum payment per second
  recipientAddress: string;   // Spirit treasury
}

// ============================================
// API Response Types
// ============================================

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  timestamp: number;
}

export interface HealthResponse {
  status: 'healthy' | 'degraded' | 'unhealthy';
  services: {
    database: boolean;
    redis: boolean;
    blockchain: boolean;
    ipfs: boolean;
  };
  version: string;
  uptime: number;
}

// ============================================
// Database Types
// ============================================

export interface AgentRecord {
  id: string;
  name: string;
  symbol: string;
  childToken: string;
  stakingPool: string;
  artist: string;
  agent: string;
  platform: string;
  merkleRoot: string;
  snapshotId: string;
  transactionHash: string;
  createdAt: Date;
  status: 'pending' | 'created' | 'failed';
}

export interface SnapshotRecord {
  id: string;
  block_number: number;
  timestamp: number;
  total_holders: number;
  total_supply_held: string;  // Stored as string for BigInt
  chain_id: number;
  created_at: Date;
}
