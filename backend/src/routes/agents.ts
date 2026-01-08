/**
 * Agent Routes
 *
 * API endpoints for agent creation and management.
 */

import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import type { Address } from 'viem';
import { snapshotService } from '../services/snapshot.js';
import { merkleService } from '../services/merkle.js';
import { priceService } from '../services/price.js';
import { validationService } from '../services/validation.js';
import { contractService } from '../services/contract.js';
import { x402Middleware } from '../middleware/x402.js';
import { config } from '../config.js';
import type { CreateAgentRequest, CreateAgentResponse, ApiResponse } from '../types/index.js';

// In-memory storage for created agents (use DB in production)
const agents: Map<string, CreateAgentResponse> = new Map();

export async function agentRoutes(fastify: FastifyInstance) {
  /**
   * POST /v1/agents/create
   *
   * Create a new agent token with staking pool and airstream.
   */
  fastify.post<{
    Body: CreateAgentRequest;
  }>(
    '/v1/agents/create',
    {
      preHandler: x402Middleware,
      schema: {
        body: {
          type: 'object',
          required: ['name', 'symbol', 'artist', 'agent', 'platform'],
          properties: {
            name: { type: 'string', minLength: 3, maxLength: 32 },
            symbol: { type: 'string', minLength: 2, maxLength: 8 },
            artist: { type: 'string', pattern: '^0x[a-fA-F0-9]{40}$' },
            agent: { type: 'string', pattern: '^0x[a-fA-F0-9]{40}$' },
            platform: { type: 'string', pattern: '^0x[a-fA-F0-9]{40}$' },
            metadataUri: { type: 'string' },
          },
        },
      },
    },
    async (request, reply) => {
      const body = request.body;

      // Validate request
      const validation = await validationService.validate(body);
      if (!validation.valid) {
        return reply.code(400).send({
          success: false,
          error: 'Validation failed',
          details: validation.errors,
          timestamp: Date.now(),
        });
      }

      try {
        // Step 1: Take snapshot of Spirit holders
        console.log(`Creating agent ${body.symbol}: Taking snapshot...`);
        const snapshot = await snapshotService.takeSnapshot();

        // Step 2: Generate merkle tree for airstream
        console.log(`Creating agent ${body.symbol}: Generating merkle tree...`);
        const tree = await merkleService.generateTree(snapshot.id);

        // Step 3: Calculate sqrtPriceX96
        console.log(`Creating agent ${body.symbol}: Calculating price...`);
        const priceData = await priceService.getSpiritPrice();
        const priceResult = priceService.calculateSqrtPrice(priceData.spiritFdv);

        // Step 4: Call contract
        console.log(`Creating agent ${body.symbol}: Submitting to contract...`);

        let childToken: string;
        let stakingPool: string;
        let transactionHash: string;

        // Check if contract service is initialized
        if (contractService.isReady()) {
          // Real contract call
          const result = await contractService.createChild({
            name: body.name,
            symbol: body.symbol,
            artist: body.artist as Address,
            agent: body.agent as Address,
            merkleRoot: tree.root as `0x${string}`,
            sqrtPriceX96: priceResult.sqrtPriceX96,
          });

          childToken = result.childToken;
          stakingPool = result.stakingPool;
          transactionHash = result.transactionHash;
        } else {
          // Mock mode for development without admin key
          console.warn('Contract service not ready - using mock data');
          transactionHash = `0x${Buffer.from(Math.random().toString()).toString('hex').slice(0, 64)}`;
          childToken = `0x${Buffer.from(body.symbol).toString('hex').padEnd(40, '0')}`;
          stakingPool = `0x${Buffer.from(body.symbol + '_pool').toString('hex').padEnd(40, '0')}`;
        }

        const response: CreateAgentResponse = {
          success: true,
          childToken,
          stakingPool,
          merkleRoot: tree.root,
          merkleTreeIpfs: tree.ipfsHash || 'pending',
          transactionHash,
          snapshotId: snapshot.id,
          blockNumber: snapshot.blockNumber,
        };

        // Store agent
        agents.set(body.symbol.toLowerCase(), response);

        console.log(`Created agent ${body.symbol} successfully`);
        return reply.code(201).send({
          success: true,
          data: response,
          timestamp: Date.now(),
        } as ApiResponse<CreateAgentResponse>);
      } catch (error) {
        console.error(`Failed to create agent ${body.symbol}:`, error);
        return reply.code(500).send({
          success: false,
          error: 'Agent creation failed',
          details: error instanceof Error ? error.message : 'Unknown error',
          timestamp: Date.now(),
        });
      }
    }
  );

  /**
   * GET /v1/agents/:symbol
   *
   * Get agent details by symbol.
   */
  fastify.get<{
    Params: { symbol: string };
  }>(
    '/v1/agents/:symbol',
    async (request, reply) => {
      const { symbol } = request.params;
      const agent = agents.get(symbol.toLowerCase());

      if (!agent) {
        return reply.code(404).send({
          success: false,
          error: 'Agent not found',
          timestamp: Date.now(),
        });
      }

      return reply.send({
        success: true,
        data: agent,
        timestamp: Date.now(),
      });
    }
  );

  /**
   * GET /v1/agents
   *
   * List all agents.
   */
  fastify.get('/v1/agents', async (request, reply) => {
    const agentList = Array.from(agents.values());
    return reply.send({
      success: true,
      data: agentList,
      count: agentList.length,
      timestamp: Date.now(),
    });
  });
}
