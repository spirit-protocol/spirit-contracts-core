/**
 * IPFS Service
 *
 * Uploads merkle trees to IPFS via Pinata.
 * Provides content-addressed storage for claim proofs.
 */

import { config } from '../config.js';

export interface PinataResponse {
  IpfsHash: string;
  PinSize: number;
  Timestamp: string;
  isDuplicate?: boolean;
}

export interface IpfsUploadResult {
  hash: string;
  url: string;
  size: number;
}

export class IpfsService {
  private apiKey: string;
  private apiSecret: string;
  private gateway: string;

  constructor() {
    this.apiKey = config.ipfs.apiKey;
    this.apiSecret = config.ipfs.apiSecret;
    this.gateway = config.ipfs.gateway;
  }

  /**
   * Check if IPFS service is configured.
   */
  isConfigured(): boolean {
    return Boolean(this.apiKey && this.apiSecret);
  }

  /**
   * Upload JSON data to IPFS via Pinata.
   */
  async uploadJson(data: object, name: string): Promise<IpfsUploadResult> {
    if (!this.isConfigured()) {
      console.warn('IPFS not configured - returning placeholder');
      return {
        hash: 'QmPlaceholder' + Math.random().toString(36).substring(7),
        url: this.gateway + 'QmPlaceholder',
        size: 0,
      };
    }

    try {
      const response = await fetch('https://api.pinata.cloud/pinning/pinJSONToIPFS', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'pinata_api_key': this.apiKey,
          'pinata_secret_api_key': this.apiSecret,
        },
        body: JSON.stringify({
          pinataContent: data,
          pinataMetadata: {
            name: name,
            keyvalues: {
              protocol: 'spirit',
              type: 'merkle-tree',
            },
          },
          pinataOptions: {
            cidVersion: 1,
          },
        }),
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`Pinata upload failed: ${response.status} - ${errorText}`);
      }

      const result = await response.json() as PinataResponse;

      return {
        hash: result.IpfsHash,
        url: this.gateway + result.IpfsHash,
        size: result.PinSize,
      };
    } catch (error) {
      console.error('IPFS upload failed:', error);
      throw error;
    }
  }

  /**
   * Upload a merkle tree to IPFS.
   */
  async uploadMerkleTree(
    treeId: string,
    treeJson: string,
    metadata: {
      snapshotId: string;
      root: string;
      leafCount: number;
      chainId: number;
    }
  ): Promise<IpfsUploadResult> {
    const data = {
      version: '1.0',
      protocol: 'spirit',
      type: 'merkle-tree',
      metadata: {
        treeId,
        ...metadata,
        createdAt: Math.floor(Date.now() / 1000),
      },
      tree: JSON.parse(treeJson),
    };

    return this.uploadJson(data, `spirit-merkle-${treeId}`);
  }

  /**
   * Fetch data from IPFS.
   */
  async fetch<T>(hash: string): Promise<T> {
    const url = this.gateway + hash;

    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`IPFS fetch failed: ${response.status}`);
    }

    return response.json() as T;
  }

  /**
   * Generate IPFS URL from hash.
   */
  getUrl(hash: string): string {
    return this.gateway + hash;
  }
}

// Singleton instance
export const ipfsService = new IpfsService();
