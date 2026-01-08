/**
 * Price Service
 *
 * Calculates sqrtPriceX96 for Uniswap V4 pool initialization.
 *
 * Source: https://uniswapv3book.com/milestone_1/calculating-liquidity.html
 *
 * Uniswap uses Q64.96 fixed-point format:
 * sqrtPriceX96 = √price × 2^96
 */

import { config } from '../config.js';
import type { PriceData, SqrtPriceResult } from '../types/index.js';

// 2^96 as BigInt for sqrtPriceX96 calculations
const Q96 = BigInt(2) ** BigInt(96);

// Spirit total supply: 1 billion tokens
const SPIRIT_TOTAL_SUPPLY = BigInt('1000000000');

export class PriceService {
  /**
   * Get current Spirit price from configured source.
   */
  async getSpiritPrice(): Promise<PriceData> {
    const source = config.pricing.priceSource;

    switch (source) {
      case 'manual':
        return this.getManualPrice();
      case 'coingecko':
        return this.getCoingeckoPrice();
      case 'dexscreener':
        return this.getDexscreenerPrice();
      case 'onchain':
        return this.getOnchainPrice();
      default:
        return this.getManualPrice();
    }
  }

  /**
   * Calculate sqrtPriceX96 for child token pool initialization.
   *
   * Pierre's explanation (Jan 8 call):
   * - Look at current USD value of Spirit
   * - Calculate ratio between Spirit FDV and target Child FDV
   * - Take square root of ratio
   * - Multiply by 2^96
   *
   * Pool is Child/Spirit pair:
   * - token0 = Child (lower address)
   * - token1 = Spirit (higher address)
   * - Price = Spirit per Child
   *
   * At equal FDV ($40K each), price = 1:1, sqrtPriceX96 = 2^96
   */
  calculateSqrtPrice(
    spiritFdv: bigint,
    childFdv: bigint = config.pricing.defaultChildFdv
  ): SqrtPriceResult {
    // Price ratio: how many Child tokens per Spirit token
    // If FDVs are equal, ratio = 1
    //
    // sqrtPriceX96 = sqrt(ratio) * 2^96
    //
    // At equal FDV: sqrtPriceX96 = 1 * 2^96 = Q96
    // At 4x FDV:    sqrtPriceX96 = 2 * 2^96 = 2*Q96

    // Calculate ratio as floating point (sufficient precision for pool init)
    const priceRatio = Number(childFdv) / Number(spiritFdv);

    // Take square root
    const sqrtRatio = Math.sqrt(priceRatio);

    // Multiply by Q96 to get sqrtPriceX96
    // For precision, we use BigInt arithmetic with scaling
    const PRECISION = BigInt(10) ** BigInt(18);
    const sqrtRatioScaled = BigInt(Math.floor(sqrtRatio * Number(PRECISION)));
    const sqrtPriceX96 = (sqrtRatioScaled * Q96) / PRECISION;

    return {
      sqrtPriceX96,
      priceRatio,
      spiritFdv,
      childFdv,
    };
  }

  /**
   * Calculate sqrtPriceX96 from Spirit USD price.
   *
   * Convenience method that first calculates Spirit FDV from price.
   */
  calculateSqrtPriceFromUsd(
    spiritPriceUsd: number,
    childTargetFdv: number = Number(config.pricing.defaultChildFdv)
  ): SqrtPriceResult {
    // Spirit FDV = price * total supply
    const spiritFdv = BigInt(Math.floor(spiritPriceUsd * Number(SPIRIT_TOTAL_SUPPLY)));
    const childFdv = BigInt(childTargetFdv);

    return this.calculateSqrtPrice(spiritFdv, childFdv);
  }

  /**
   * Verify sqrtPriceX96 is within reasonable bounds.
   */
  validateSqrtPrice(sqrtPriceX96: bigint): boolean {
    // Minimum: 0.01x ratio (sqrt(0.01) * 2^96)
    const minSqrt = Q96 / BigInt(10);

    // Maximum: 100x ratio (sqrt(100) * 2^96)
    const maxSqrt = Q96 * BigInt(10);

    return sqrtPriceX96 >= minSqrt && sqrtPriceX96 <= maxSqrt;
  }

  /**
   * Decode sqrtPriceX96 back to price ratio (for verification).
   */
  decodePrice(sqrtPriceX96: bigint): number {
    // price = (sqrtPriceX96 / 2^96)^2
    const sqrtRatio = Number(sqrtPriceX96) / Number(Q96);
    return sqrtRatio * sqrtRatio;
  }

  // ============================================
  // Price Sources
  // ============================================

  private getManualPrice(): PriceData {
    const spiritPriceUsd = config.pricing.manualSpiritPrice;
    const spiritFdv = BigInt(Math.floor(spiritPriceUsd * Number(SPIRIT_TOTAL_SUPPLY)));

    return {
      spiritPriceUsd,
      spiritFdv,
      source: 'manual',
      timestamp: Math.floor(Date.now() / 1000),
    };
  }

  private async getCoingeckoPrice(): Promise<PriceData> {
    // TODO: Implement CoinGecko API integration
    // For now, fall back to manual
    console.warn('CoinGecko price source not implemented, using manual');
    return this.getManualPrice();
  }

  private async getDexscreenerPrice(): Promise<PriceData> {
    // TODO: Implement DEXScreener API integration
    // For now, fall back to manual
    console.warn('DEXScreener price source not implemented, using manual');
    return this.getManualPrice();
  }

  private async getOnchainPrice(): Promise<PriceData> {
    // TODO: Implement onchain TWAP from Uniswap pool
    // For now, fall back to manual
    console.warn('Onchain price source not implemented, using manual');
    return this.getManualPrice();
  }

  // ============================================
  // Math Utilities
  // ============================================

  /**
   * Integer square root using Newton's method.
   */
  private sqrt(n: bigint): bigint {
    if (n < BigInt(0)) {
      throw new Error('Square root of negative number');
    }
    if (n === BigInt(0)) return BigInt(0);
    if (n === BigInt(1)) return BigInt(1);

    // Initial guess
    let x = n;
    let y = (x + BigInt(1)) / BigInt(2);

    // Newton's method iterations
    while (y < x) {
      x = y;
      y = (x + n / x) / BigInt(2);
    }

    return x;
  }
}

// Singleton instance
export const priceService = new PriceService();

// ============================================
// Export constants for testing
// ============================================
export { Q96, SPIRIT_TOTAL_SUPPLY };
