/**
 * Snapshot Routes
 *
 * API endpoints for Spirit holder snapshots.
 */

import type { FastifyInstance } from 'fastify';
import { snapshotService } from '../services/snapshot.js';
import type { ApiResponse, Snapshot, Holder } from '../types/index.js';

export async function snapshotRoutes(fastify: FastifyInstance) {
  /**
   * POST /v1/snapshots
   *
   * Create a new snapshot of Spirit holders.
   * Admin-only in production.
   */
  fastify.post(
    '/v1/snapshots',
    async (request, reply) => {
      try {
        const snapshot = await snapshotService.takeSnapshot();

        return reply.code(201).send({
          success: true,
          data: {
            ...snapshot,
            totalSupplyHeld: snapshot.totalSupplyHeld.toString(),
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
   * GET /v1/snapshots/:id
   *
   * Get snapshot metadata by ID.
   */
  fastify.get<{
    Params: { id: string };
  }>(
    '/v1/snapshots/:id',
    async (request, reply) => {
      const { id } = request.params;

      try {
        const snapshot = await snapshotService.getSnapshot(id);

        if (!snapshot) {
          return reply.code(404).send({
            success: false,
            error: 'Snapshot not found',
            timestamp: Date.now(),
          });
        }

        return reply.send({
          success: true,
          data: {
            ...snapshot,
            totalSupplyHeld: snapshot.totalSupplyHeld.toString(),
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
   * GET /v1/snapshots/:id/holders
   *
   * Get all holders from a snapshot.
   */
  fastify.get<{
    Params: { id: string };
    Querystring: { limit?: number; offset?: number };
  }>(
    '/v1/snapshots/:id/holders',
    {
      schema: {
        querystring: {
          type: 'object',
          properties: {
            limit: { type: 'number', default: 100, maximum: 1000 },
            offset: { type: 'number', default: 0 },
          },
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params;
      const { limit = 100, offset = 0 } = request.query;

      try {
        const holders = await snapshotService.getHolders(id);
        const paginatedHolders = holders.slice(offset, offset + limit);

        return reply.send({
          success: true,
          data: paginatedHolders.map(h => ({
            address: h.address,
            balance: h.balance.toString(),
            percentOfSupply: h.percentOfSupply,
          })),
          pagination: {
            total: holders.length,
            limit,
            offset,
            hasMore: offset + limit < holders.length,
          },
          timestamp: Date.now(),
        });
      } catch (error) {
        if (error instanceof Error && error.message.includes('not found')) {
          return reply.code(404).send({
            success: false,
            error: error.message,
            timestamp: Date.now(),
          });
        }
        return reply.code(500).send({
          success: false,
          error: error instanceof Error ? error.message : 'Unknown error',
          timestamp: Date.now(),
        });
      }
    }
  );

  /**
   * GET /v1/snapshots/:id/holder/:address
   *
   * Get a specific holder from a snapshot.
   */
  fastify.get<{
    Params: { id: string; address: string };
  }>(
    '/v1/snapshots/:id/holder/:address',
    async (request, reply) => {
      const { id, address } = request.params;

      // Validate address
      if (!/^0x[a-fA-F0-9]{40}$/.test(address)) {
        return reply.code(400).send({
          success: false,
          error: 'Invalid address format',
          timestamp: Date.now(),
        });
      }

      try {
        const holders = await snapshotService.getHolders(id);
        const holder = holders.find(
          h => h.address.toLowerCase() === address.toLowerCase()
        );

        if (!holder) {
          return reply.code(404).send({
            success: false,
            error: 'Address not found in snapshot',
            timestamp: Date.now(),
          });
        }

        return reply.send({
          success: true,
          data: {
            address: holder.address,
            balance: holder.balance.toString(),
            percentOfSupply: holder.percentOfSupply,
          },
          timestamp: Date.now(),
        });
      } catch (error) {
        if (error instanceof Error && error.message.includes('not found')) {
          return reply.code(404).send({
            success: false,
            error: error.message,
            timestamp: Date.now(),
          });
        }
        return reply.code(500).send({
          success: false,
          error: error instanceof Error ? error.message : 'Unknown error',
          timestamp: Date.now(),
        });
      }
    }
  );
}
