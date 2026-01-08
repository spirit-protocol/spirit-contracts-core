/**
 * Spirit Protocol Backend Server
 *
 * Self-service API for agent creation on Spirit Protocol.
 * Backend-controlled architecture per Pierre's recommendation (Jan 8, 2026).
 *
 * Flow:
 * 1. Agent calls API (with x402 payment if enabled)
 * 2. Backend validates request
 * 3. Backend takes Spirit holder snapshot
 * 4. Backend generates merkle tree
 * 5. Backend calculates sqrtPriceX96
 * 6. Backend calls createChild on SpiritFactory contract
 * 7. Agent token created with staking pool and airstream
 */

import Fastify from 'fastify';
import cors from '@fastify/cors';
import { config, validateConfig } from './config.js';
import { healthRoutes } from './routes/health.js';
import { agentRoutes } from './routes/agents.js';
import { merkleRoutes } from './routes/merkle.js';
import { snapshotRoutes } from './routes/snapshots.js';
import { priceRoutes } from './routes/price.js';

// Validate configuration before starting
validateConfig();

// Create Fastify instance
const fastify = Fastify({
  logger: {
    level: config.environment === 'development' ? 'debug' : 'info',
    transport: config.environment === 'development'
      ? {
          target: 'pino-pretty',
          options: {
            translateTime: 'HH:MM:ss Z',
            ignore: 'pid,hostname',
          },
        }
      : undefined,
  },
});

// Register CORS
await fastify.register(cors, {
  origin: true, // Allow all origins in development
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
});

// Register routes
await fastify.register(healthRoutes);
await fastify.register(agentRoutes);
await fastify.register(merkleRoutes);
await fastify.register(snapshotRoutes);
await fastify.register(priceRoutes);

// Root route
fastify.get('/', async (request, reply) => {
  return reply.send({
    name: 'Spirit Protocol Backend',
    version: '0.1.0',
    description: 'Self-service API for agent creation on Spirit Protocol',
    documentation: {
      protocol: 'https://spiritprotocol.io/',
      llm: 'https://spiritprotocol.io/llm.txt',
      api: '/info',
    },
    endpoints: {
      health: '/health',
      agents: '/v1/agents',
      snapshots: '/v1/snapshots',
      merkle: '/v1/merkle',
      price: '/v1/price',
    },
  });
});

// Error handler
fastify.setErrorHandler((error, request, reply) => {
  fastify.log.error(error);

  // Don't expose internal errors in production
  const message = config.environment === 'development'
    ? error.message
    : 'Internal server error';

  reply.code(error.statusCode || 500).send({
    success: false,
    error: message,
    timestamp: Date.now(),
  });
});

// Start server
async function start() {
  try {
    await fastify.listen({
      port: config.port,
      host: config.host,
    });

    console.log(`
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║   Spirit Protocol Backend v0.1.0                         ║
║                                                          ║
║   Server running at http://${config.host}:${config.port}               ║
║                                                          ║
║   Endpoints:                                             ║
║   - GET  /health          Health check                   ║
║   - GET  /info            Service info                   ║
║   - POST /v1/agents/create Create agent (x402)          ║
║   - GET  /v1/agents/:symbol Get agent                    ║
║   - POST /v1/snapshots    Take snapshot                  ║
║   - GET  /v1/merkle/:id/proof/:addr Get proof           ║
║   - GET  /v1/price/sqrt   Calculate sqrtPriceX96        ║
║                                                          ║
║   Environment: ${config.environment.padEnd(39)}║
║   Chain: Base Sepolia (${config.blockchain.chainId})                         ║
║   x402 Payments: ${config.x402.enabled ? 'Enabled ' : 'Disabled'}                              ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
`);
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
}

start();
