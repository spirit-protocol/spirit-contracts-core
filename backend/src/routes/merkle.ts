/**
 * Merkle Routes
 *
 * API endpoints for merkle tree and proof operations.
 */

import type { FastifyInstance } from 'fastify';
import { merkleService } from '../services/merkle.js';
import type { ApiResponse, MerkleTree, MerkleProof } from '../types/index.js';

export async function merkleRoutes(fastify: FastifyInstance) {
  /**
   * GET /v1/merkle/:treeId
   *
   * Get merkle tree metadata.
   */
  fastify.get<{
    Params: { treeId: string };
  }>(
    '/v1/merkle/:treeId',
    async (request, reply) => {
      const { treeId } = request.params;

      try {
        const tree = await merkleService.getTree(treeId);

        if (!tree) {
          return reply.code(404).send({
            success: false,
            error: 'Merkle tree not found',
            timestamp: Date.now(),
          });
        }

        return reply.send({
          success: true,
          data: tree,
          timestamp: Date.now(),
        } as ApiResponse<MerkleTree>);
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
   * GET /v1/merkle/:treeId/proof/:address
   *
   * Get merkle proof for an address.
   * Used by holders to claim their airstream allocation.
   */
  fastify.get<{
    Params: { treeId: string; address: string };
  }>(
    '/v1/merkle/:treeId/proof/:address',
    async (request, reply) => {
      const { treeId, address } = request.params;

      // Validate address format
      if (!/^0x[a-fA-F0-9]{40}$/.test(address)) {
        return reply.code(400).send({
          success: false,
          error: 'Invalid address format',
          timestamp: Date.now(),
        });
      }

      try {
        const proof = await merkleService.getProof(treeId, address);

        return reply.send({
          success: true,
          data: {
            address: proof.address,
            amount: proof.amount.toString(),
            proof: proof.proof,
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
   * POST /v1/merkle/:treeId/verify
   *
   * Verify a merkle proof.
   */
  fastify.post<{
    Params: { treeId: string };
    Body: { address: string; amount: string; proof: string[] };
  }>(
    '/v1/merkle/:treeId/verify',
    {
      schema: {
        body: {
          type: 'object',
          required: ['address', 'amount', 'proof'],
          properties: {
            address: { type: 'string', pattern: '^0x[a-fA-F0-9]{40}$' },
            amount: { type: 'string' },
            proof: { type: 'array', items: { type: 'string' } },
          },
        },
      },
    },
    async (request, reply) => {
      const { treeId } = request.params;
      const { address, amount, proof } = request.body;

      try {
        const tree = await merkleService.getTree(treeId);
        if (!tree) {
          return reply.code(404).send({
            success: false,
            error: 'Merkle tree not found',
            timestamp: Date.now(),
          });
        }

        const valid = merkleService.verifyProof(
          tree.root,
          proof,
          address,
          BigInt(amount)
        );

        return reply.send({
          success: true,
          data: { valid },
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
   * GET /v1/merkle/:treeId/leaves
   *
   * Get all leaves in a merkle tree.
   * Returns the full allocation list (address, amount pairs).
   */
  fastify.get<{
    Params: { treeId: string };
  }>(
    '/v1/merkle/:treeId/leaves',
    async (request, reply) => {
      const { treeId } = request.params;

      try {
        const leaves = await merkleService.getLeaves(treeId);

        return reply.send({
          success: true,
          data: leaves.map(l => ({
            address: l.address,
            amount: l.amount.toString(),
          })),
          count: leaves.length,
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
   * GET /v1/merkle/:treeId/export
   *
   * Export full merkle tree JSON.
   * Used for IPFS upload and independent verification.
   */
  fastify.get<{
    Params: { treeId: string };
  }>(
    '/v1/merkle/:treeId/export',
    async (request, reply) => {
      const { treeId } = request.params;

      try {
        const json = await merkleService.exportTree(treeId);

        return reply
          .header('Content-Type', 'application/json')
          .header('Content-Disposition', `attachment; filename="${treeId}.json"`)
          .send(json);
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
