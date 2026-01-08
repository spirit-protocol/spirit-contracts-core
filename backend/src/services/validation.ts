/**
 * Validation Service
 *
 * Validates agent creation requests before processing.
 * Enforces rate limits, parameter rules, and platform approval.
 */

import { config } from '../config.js';
import type { CreateAgentRequest, ValidationResult } from '../types/index.js';

// In-memory rate limiting (use Redis in production)
const requestCounts: Map<string, { count: number; resetTime: number }> = new Map();

export class ValidationService {
  /**
   * Validate an agent creation request.
   */
  async validate(request: CreateAgentRequest): Promise<ValidationResult> {
    const errors: string[] = [];

    // Name validation
    if (!request.name || request.name.length < config.validation.nameMinLength) {
      errors.push(`Name must be at least ${config.validation.nameMinLength} characters`);
    }
    if (request.name && request.name.length > config.validation.nameMaxLength) {
      errors.push(`Name must be at most ${config.validation.nameMaxLength} characters`);
    }
    if (request.name && !/^[a-zA-Z0-9\s]+$/.test(request.name)) {
      errors.push('Name must contain only alphanumeric characters and spaces');
    }

    // Symbol validation
    if (!request.symbol || request.symbol.length < config.validation.symbolMinLength) {
      errors.push(`Symbol must be at least ${config.validation.symbolMinLength} characters`);
    }
    if (request.symbol && request.symbol.length > config.validation.symbolMaxLength) {
      errors.push(`Symbol must be at most ${config.validation.symbolMaxLength} characters`);
    }
    if (request.symbol && !/^[A-Z0-9]+$/.test(request.symbol)) {
      errors.push('Symbol must contain only uppercase letters and numbers');
    }

    // Address validation
    if (!this.isValidAddress(request.artist)) {
      errors.push('Invalid artist address');
    }
    if (!this.isValidAddress(request.agent)) {
      errors.push('Invalid agent address');
    }
    if (!this.isValidAddress(request.platform)) {
      errors.push('Invalid platform address');
    }

    // Platform approval
    if (config.validation.requirePlatformApproval) {
      if (!this.isPlatformApproved(request.platform)) {
        errors.push(`Platform ${request.platform} is not approved`);
      }
    }

    // Rate limiting
    const rateLimitResult = await this.checkRateLimit(request.artist);
    if (!rateLimitResult.allowed) {
      errors.push(rateLimitResult.reason || 'Rate limit exceeded');
    }

    return {
      valid: errors.length === 0,
      errors,
    };
  }

  /**
   * Check if an address is valid Ethereum address.
   */
  private isValidAddress(address: string): boolean {
    if (!address) return false;
    return /^0x[a-fA-F0-9]{40}$/.test(address);
  }

  /**
   * Check if a platform is approved.
   */
  private isPlatformApproved(platform: string): boolean {
    if (config.validation.approvedPlatforms.length === 0) {
      // No whitelist = all platforms allowed
      return true;
    }
    return config.validation.approvedPlatforms.some(
      p => p.toLowerCase() === platform.toLowerCase()
    );
  }

  /**
   * Check rate limits for an address.
   */
  private async checkRateLimit(
    address: string
  ): Promise<{ allowed: boolean; reason?: string }> {
    const now = Date.now();
    const resetPeriod = 24 * 60 * 60 * 1000; // 24 hours

    const key = address.toLowerCase();
    let entry = requestCounts.get(key);

    // Reset if period expired
    if (entry && now > entry.resetTime) {
      entry = undefined;
      requestCounts.delete(key);
    }

    // Check per-address limit
    if (entry && entry.count >= config.validation.maxCreationsPerAddress) {
      return {
        allowed: false,
        reason: `Rate limit exceeded: max ${config.validation.maxCreationsPerAddress} creations per 24 hours`,
      };
    }

    // Update count
    if (entry) {
      entry.count++;
    } else {
      requestCounts.set(key, {
        count: 1,
        resetTime: now + resetPeriod,
      });
    }

    return { allowed: true };
  }

  /**
   * Get remaining rate limit for an address.
   */
  getRemainingLimit(address: string): number {
    const key = address.toLowerCase();
    const entry = requestCounts.get(key);

    if (!entry || Date.now() > entry.resetTime) {
      return config.validation.maxCreationsPerAddress;
    }

    return Math.max(0, config.validation.maxCreationsPerAddress - entry.count);
  }

  /**
   * Reset rate limit for an address (admin function).
   */
  resetRateLimit(address: string): void {
    requestCounts.delete(address.toLowerCase());
  }
}

// Singleton instance
export const validationService = new ValidationService();
