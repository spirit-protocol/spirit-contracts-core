/**
 * Price Routes
 *
 * API endpoints for price calculation and sqrtPriceX96.
 */

import type { FastifyInstance } from 'fastify';
import { priceService, Q96 } from '../services/price.js';
import { config } from '../config.js';
import type { ApiResponse } from '../types/index.js';

export async function priceRoutes(fastify: FastifyInstance) {
  /**
   * GET /v1/price/spirit
   *
   * Get current Spirit price and FDV.
   */
  fastify.get(
    '/v1/price/spirit',
    async (request, reply) => {
      try {
        const priceData = await priceService.getSpiritPrice();

        return reply.send({
          success: true,
          data: {
            priceUsd: priceData.spiritPriceUsd,
            fdv: priceData.spiritFdv.toString(),
            source: priceData.source,
            timestamp: priceData.timestamp,
          },
          timestamp: Date.now(),
        });
      } catch (error) {
        return reply.code(500).send({
          success: false,
          error: error instanceof Error ? error.message : 'Unknown error',
          timestamp: Date.now(),
        });
      }
    }
  );

  /**
   * GET /v1/price/sqrt
   *
   * Calculate sqrtPriceX96 for a child token.
   */
  fastify.get<{
    Querystring: { childFdv?: string };
  }>(
    '/v1/price/sqrt',
    {
      schema: {
        querystring: {
          type: 'object',
          properties: {
            childFdv: { type: 'string', default: '40000' },
          },
        },
      },
    },
    async (request, reply) => {
      const { childFdv = '40000' } = request.query;

      try {
        const priceData = await priceService.getSpiritPrice();
        const result = priceService.calculateSqrtPrice(
          priceData.spiritFdv,
          BigInt(childFdv)
        );

        // Validate the price
        const isValid = priceService.validateSqrtPrice(result.sqrtPriceX96);

        return reply.send({
          success: true,
          data: {
            sqrtPriceX96: result.sqrtPriceX96.toString(),
            sqrtPriceX96Hex: '0x' + result.sqrtPriceX96.toString(16),
            priceRatio: result.priceRatio,
            spiritFdv: result.spiritFdv.toString(),
            childFdv: result.childFdv.toString(),
            isValid,
            source: priceData.source,
            formula: 'sqrtPriceX96 = sqrt(childFdv / spiritFdv) * 2^96',
            reference: 'https://uniswapv3book.com/milestone_1/calculating-liquidity.html',
          },
          timestamp: Date.now(),
        });
      } catch (error) {
        return reply.code(500).send({
          success: false,
          error: error instanceof Error ? error.message : 'Unknown error',
          timestamp: Date.now(),
        });
      }
    }
  );

  /**
   * POST /v1/price/sqrt/calculate
   *
   * Calculate sqrtPriceX96 with custom FDV values.
   */
  fastify.post<{
    Body: { spiritFdv: string; childFdv: string };
  }>(
    '/v1/price/sqrt/calculate',
    {
      schema: {
        body: {
          type: 'object',
          required: ['spiritFdv', 'childFdv'],
          properties: {
            spiritFdv: { type: 'string' },
            childFdv: { type: 'string' },
          },
        },
      },
    },
    async (request, reply) => {
      const { spiritFdv, childFdv } = request.body;

      try {
        const result = priceService.calculateSqrtPrice(
          BigInt(spiritFdv),
          BigInt(childFdv)
        );

        const isValid = priceService.validateSqrtPrice(result.sqrtPriceX96);

        return reply.send({
          success: true,
          data: {
            sqrtPriceX96: result.sqrtPriceX96.toString(),
            sqrtPriceX96Hex: '0x' + result.sqrtPriceX96.toString(16),
            priceRatio: result.priceRatio,
            spiritFdv: result.spiritFdv.toString(),
            childFdv: result.childFdv.toString(),
            isValid,
          },
          timestamp: Date.now(),
        });
      } catch (error) {
        return reply.code(500).send({
          success: false,
          error: error instanceof Error ? error.message : 'Unknown error',
          timestamp: Date.now(),
        });
      }
    }
  );

  /**
   * POST /v1/price/sqrt/decode
   *
   * Decode sqrtPriceX96 back to price ratio.
   */
  fastify.post<{
    Body: { sqrtPriceX96: string };
  }>(
    '/v1/price/sqrt/decode',
    {
      schema: {
        body: {
          type: 'object',
          required: ['sqrtPriceX96'],
          properties: {
            sqrtPriceX96: { type: 'string' },
          },
        },
      },
    },
    async (request, reply) => {
      const { sqrtPriceX96 } = request.body;

      try {
        const sqrtPrice = BigInt(sqrtPriceX96);
        const priceRatio = priceService.decodePrice(sqrtPrice);
        const isValid = priceService.validateSqrtPrice(sqrtPrice);

        return reply.send({
          success: true,
          data: {
            sqrtPriceX96: sqrtPrice.toString(),
            priceRatio,
            priceRatioDisplay: priceRatio.toFixed(6),
            isValid,
            interpretation: `1 Spirit = ${priceRatio.toFixed(6)} Child tokens`,
          },
          timestamp: Date.now(),
        });
      } catch (error) {
        return reply.code(400).send({
          success: false,
          error: error instanceof Error ? error.message : 'Invalid sqrtPriceX96',
          timestamp: Date.now(),
        });
      }
    }
  );

  /**
   * GET /v1/price/constants
   *
   * Get pricing constants and configuration.
   */
  fastify.get(
    '/v1/price/constants',
    async (request, reply) => {
      return reply.send({
        success: true,
        data: {
          Q96: Q96.toString(),
          Q96_HEX: '0x' + Q96.toString(16),
          spiritTotalSupply: config.pricing.spiritTotalSupply.toString(),
          defaultChildFdv: config.pricing.defaultChildFdv.toString(),
          priceSource: config.pricing.priceSource,
          chainId: config.blockchain.chainId,
        },
        timestamp: Date.now(),
      });
    }
  );
}
