/**
 * Spirit Protocol Backend Configuration
 */

import dotenv from 'dotenv';
dotenv.config();

export const config = {
  // Server
  port: parseInt(process.env.PORT || '3000'),
  host: process.env.HOST || '0.0.0.0',
  environment: process.env.NODE_ENV || 'development',

  // Database
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    name: process.env.DB_NAME || 'spirit_backend',
    user: process.env.DB_USER || 'spirit',
    password: process.env.DB_PASSWORD || '',
  },

  // Redis
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379'),
    password: process.env.REDIS_PASSWORD || undefined,
  },

  // Blockchain
  blockchain: {
    rpcUrl: process.env.RPC_URL || 'https://sepolia.base.org',
    chainId: parseInt(process.env.CHAIN_ID || '84532'), // Base Sepolia
    spiritTokenAddress: process.env.SPIRIT_TOKEN_ADDRESS || '0xc7e9de362C6eA2Cc03863ECe330622146Ff1c18B',
    spiritFactoryAddress: process.env.SPIRIT_FACTORY_ADDRESS || '0x879d67000C938142F472fB8f2ee0b6601E2cE3C6',
    adminPrivateKey: process.env.ADMIN_PRIVATE_KEY || '', // NEVER commit this
  },

  // IPFS
  ipfs: {
    gateway: process.env.IPFS_GATEWAY || 'https://gateway.pinata.cloud/ipfs/',
    apiKey: process.env.PINATA_API_KEY || '',
    apiSecret: process.env.PINATA_API_SECRET || '',
  },

  // x402 / Superfluid
  x402: {
    superfluidHost: process.env.SUPERFLUID_HOST || '0x4C073B3baB6d8826b8C5b229f3cfdC1eC6E47E74',
    acceptedToken: process.env.X402_ACCEPTED_TOKEN || '', // USDCx or similar
    minimumFlowRate: BigInt(process.env.X402_MIN_FLOW_RATE || '0'), // tokens per second
    recipientAddress: process.env.X402_RECIPIENT || '', // Spirit treasury
    enabled: process.env.X402_ENABLED === 'true',
  },

  // Validation Rules
  validation: {
    maxCreationsPerDay: parseInt(process.env.MAX_CREATIONS_PER_DAY || '10'),
    maxCreationsPerAddress: parseInt(process.env.MAX_CREATIONS_PER_ADDRESS || '1'),
    nameMinLength: 3,
    nameMaxLength: 32,
    symbolMinLength: 2,
    symbolMaxLength: 8,
    approvedPlatforms: (process.env.APPROVED_PLATFORMS || '').split(',').filter(Boolean),
    requirePlatformApproval: process.env.REQUIRE_PLATFORM_APPROVAL !== 'false',
    minimumSpiritHeld: BigInt(process.env.MIN_SPIRIT_HELD || '0'),
  },

  // Price Service
  pricing: {
    spiritTotalSupply: BigInt('1000000000'), // 1B
    defaultChildFdv: BigInt('40000'),        // $40K default
    priceSource: process.env.PRICE_SOURCE || 'manual' as const,
    manualSpiritPrice: parseFloat(process.env.MANUAL_SPIRIT_PRICE || '0.00004'), // $0.00004 = $40K FDV
  },
} as const;

// Validate required config
export function validateConfig(): void {
  const errors: string[] = [];

  if (!config.blockchain.adminPrivateKey && config.environment === 'production') {
    errors.push('ADMIN_PRIVATE_KEY is required in production');
  }

  if (config.x402.enabled && !config.x402.acceptedToken) {
    errors.push('X402_ACCEPTED_TOKEN is required when x402 is enabled');
  }

  if (errors.length > 0) {
    throw new Error(`Configuration errors:\n${errors.join('\n')}`);
  }
}
