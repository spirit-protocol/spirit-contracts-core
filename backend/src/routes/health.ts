/**
 * Health Routes
 *
 * API endpoints for service health and status.
 */

import type { FastifyInstance } from 'fastify';
import { createPublicClient, http } from 'viem';
import { baseSepolia } from 'viem/chains';
import { config } from '../config.js';
import type { HealthResponse } from '../types/index.js';

// Track server start time for uptime calculation
const startTime = Date.now();

export async function healthRoutes(fastify: FastifyInstance) {
  /**
   * GET /health
   *
   * Basic health check.
   */
  fastify.get('/health', async (request, reply) => {
    return reply.send({
      status: 'ok',
      timestamp: Date.now(),
    });
  });

  /**
   * GET /health/detailed
   *
   * Detailed health check with service status.
   */
  fastify.get('/health/detailed', async (request, reply) => {
    const services = {
      database: false, // TODO: Check DB connection
      redis: false,    // TODO: Check Redis connection
      blockchain: false,
      ipfs: false,     // TODO: Check IPFS gateway
    };

    // Check blockchain connection
    try {
      const client = createPublicClient({
        chain: baseSepolia,
        transport: http(config.blockchain.rpcUrl),
      });
      await client.getBlockNumber();
      services.blockchain = true;
    } catch (error) {
      console.error('Blockchain health check failed:', error);
    }

    // Determine overall status
    const criticalServices = services.blockchain;
    const status: HealthResponse['status'] = criticalServices
      ? 'healthy'
      : 'degraded';

    return reply.send({
      status,
      services,
      version: '0.1.0',
      uptime: Math.floor((Date.now() - startTime) / 1000),
    } as HealthResponse);
  });

  /**
   * GET /health/ready
   *
   * Readiness check for load balancers.
   */
  fastify.get('/health/ready', async (request, reply) => {
    // Check if service is ready to accept traffic
    try {
      const client = createPublicClient({
        chain: baseSepolia,
        transport: http(config.blockchain.rpcUrl),
      });
      await client.getBlockNumber();

      return reply.code(200).send({
        ready: true,
        timestamp: Date.now(),
      });
    } catch (error) {
      return reply.code(503).send({
        ready: false,
        error: 'Blockchain connection unavailable',
        timestamp: Date.now(),
      });
    }
  });

  /**
   * GET /health/live
   *
   * Liveness check for container orchestration.
   */
  fastify.get('/health/live', async (request, reply) => {
    // Simple check that the process is alive
    return reply.code(200).send({
      alive: true,
      timestamp: Date.now(),
    });
  });

  /**
   * GET /info
   *
   * Service information.
   */
  fastify.get('/info', async (request, reply) => {
    return reply.send({
      name: '@spirit-protocol/backend',
      version: '0.1.0',
      environment: config.environment,
      chainId: config.blockchain.chainId,
      network: 'base-sepolia',
      contracts: {
        spiritToken: config.blockchain.spiritTokenAddress,
        spiritFactory: config.blockchain.spiritFactoryAddress,
      },
      features: {
        x402Enabled: config.x402.enabled,
        snapshotService: true,
        merkleService: true,
        priceService: true,
      },
      documentation: {
        api: '/docs',
        x402: 'https://x402.superfluid.org/',
        spirit: 'https://spiritprotocol.io/',
      },
      timestamp: Date.now(),
    });
  });
}
