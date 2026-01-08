/**
 * ID Generation Utilities
 */

import { randomBytes } from 'crypto';

/**
 * Generate a unique ID with optional prefix.
 *
 * Format: prefix_timestamp_random
 * Example: snap_1704721234_a1b2c3d4
 */
export function generateId(prefix?: string): string {
  const timestamp = Math.floor(Date.now() / 1000);
  const random = randomBytes(4).toString('hex');
  return prefix ? `${prefix}_${timestamp}_${random}` : `${timestamp}_${random}`;
}

/**
 * Generate a deterministic ID from inputs.
 * Useful for idempotent operations.
 */
export function deterministicId(...inputs: string[]): string {
  const crypto = require('crypto');
  const hash = crypto.createHash('sha256');
  for (const input of inputs) {
    hash.update(input);
  }
  return hash.digest('hex').slice(0, 16);
}
