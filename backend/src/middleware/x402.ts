/**
 * x402 Payment Middleware
 *
 * Implements HTTP 402 Payment Required for API monetization.
 * Uses Superfluid streaming payments via x402 protocol.
 *
 * Source: https://x402.superfluid.org/
 *
 * Flow:
 * 1. Agent opens Superfluid stream to Spirit treasury
 * 2. Agent makes API call with payment proof header
 * 3. Middleware verifies stream is active and sufficient
 * 4. If valid, request proceeds
 * 5. If insufficient, returns 402 Payment Required
 */

import type { FastifyRequest, FastifyReply, HookHandlerDoneFunction } from 'fastify';
import { createPublicClient, http, parseAbi } from 'viem';
import { baseSepolia } from 'viem/chains';
import { config } from '../config.js';
import type { X402PaymentProof } from '../types/index.js';

// Superfluid CFA (Constant Flow Agreement) ABI for flow queries
// This is the canonical way to query active streams in Superfluid
const CFA_ABI = parseAbi([
  'function getFlow(address token, address sender, address receiver) external view returns (uint256 timestamp, int96 flowRate, uint256 deposit, uint256 owedDeposit)',
  'function getNetFlow(address token, address account) external view returns (int96 flowRate)',
]);

// CFA Forwarder on Base Sepolia
// See: https://docs.superfluid.finance/docs/protocol/contract-addresses
const CFA_FORWARDER_ADDRESS = '0xcfA132E353cB4E398080B9700609bb008eceB125' as const;

// Header name for x402 payment proof
const X402_HEADER = 'x-402-payment';

/**
 * x402 Middleware Factory
 *
 * Creates middleware that verifies Superfluid payment streams.
 */
export function x402Middleware(
  request: FastifyRequest,
  reply: FastifyReply,
  done: HookHandlerDoneFunction
) {
  // Skip x402 if disabled
  if (!config.x402.enabled) {
    done();
    return;
  }

  // Check for payment header
  const paymentHeader = request.headers[X402_HEADER];
  if (!paymentHeader || typeof paymentHeader !== 'string') {
    reply.code(402).send({
      error: 'Payment Required',
      message: 'This endpoint requires x402 payment',
      details: {
        acceptedToken: config.x402.acceptedToken,
        minimumFlowRate: config.x402.minimumFlowRate.toString(),
        recipientAddress: config.x402.recipientAddress,
        protocol: 'x402',
        documentation: 'https://x402.superfluid.org/',
      },
    });
    return;
  }

  // Parse payment proof
  let proof: X402PaymentProof;
  try {
    proof = JSON.parse(paymentHeader);
  } catch {
    reply.code(400).send({
      error: 'Invalid Payment Proof',
      message: 'Could not parse x-402-payment header',
    });
    return;
  }

  // Verify payment asynchronously
  verifyPayment(proof)
    .then(valid => {
      if (valid) {
        // Store sender for logging/attribution
        (request as any).x402Sender = proof.sender;
        done();
      } else {
        reply.code(402).send({
          error: 'Payment Required',
          message: 'Payment stream is insufficient or inactive',
          details: {
            acceptedToken: config.x402.acceptedToken,
            minimumFlowRate: config.x402.minimumFlowRate.toString(),
            recipientAddress: config.x402.recipientAddress,
          },
        });
      }
    })
    .catch(err => {
      console.error('x402 verification error:', err);
      reply.code(500).send({
        error: 'Payment Verification Failed',
        message: 'Could not verify payment stream',
      });
    });
}

/**
 * Verify a Superfluid payment stream onchain.
 *
 * Flow:
 * 1. Query CFA Forwarder for active flow from sender to recipient
 * 2. Verify flow rate meets minimum requirement
 * 3. Verify flow is currently active (timestamp > 0)
 */
async function verifyPayment(proof: X402PaymentProof): Promise<boolean> {
  try {
    // Basic parameter validation
    if (!proof.sender || !proof.flowRate) {
      console.log('x402: Missing sender or flowRate in proof');
      return false;
    }

    // Check flow rate meets minimum
    const claimedFlowRate = BigInt(proof.flowRate);
    if (claimedFlowRate < config.x402.minimumFlowRate) {
      console.log(`x402: Flow rate ${claimedFlowRate} below minimum ${config.x402.minimumFlowRate}`);
      return false;
    }

    // Verify onchain
    const client = createPublicClient({
      chain: baseSepolia,
      transport: http(config.blockchain.rpcUrl),
    });

    const acceptedToken = config.x402.acceptedToken as `0x${string}`;
    const recipient = config.x402.recipientAddress as `0x${string}`;
    const sender = proof.sender as `0x${string}`;

    // Query the actual flow from Superfluid CFA Forwarder
    const [timestamp, flowRate] = await client.readContract({
      address: CFA_FORWARDER_ADDRESS,
      abi: CFA_ABI,
      functionName: 'getFlow',
      args: [acceptedToken, sender, recipient],
    }) as [bigint, bigint, bigint, bigint];

    // Check if stream is active (timestamp > 0 means stream exists)
    if (timestamp === BigInt(0)) {
      console.log(`x402: No active stream from ${sender} to ${recipient}`);
      return false;
    }

    // Check actual flow rate meets minimum
    if (flowRate < config.x402.minimumFlowRate) {
      console.log(`x402: Actual flow rate ${flowRate} below minimum ${config.x402.minimumFlowRate}`);
      return false;
    }

    console.log(`x402: Verified stream from ${sender} with rate ${flowRate}`);
    return true;
  } catch (error) {
    console.error('x402 verification error:', error);
    return false;
  }
}

/**
 * Generate payment instructions for 402 response.
 */
export function generatePaymentInstructions(): object {
  return {
    protocol: 'x402',
    version: '1.0',
    network: 'base-sepolia',
    chainId: config.blockchain.chainId,
    acceptedToken: config.x402.acceptedToken,
    recipient: config.x402.recipientAddress,
    minimumFlowRate: config.x402.minimumFlowRate.toString(),
    flowRateUnit: 'tokens per second (18 decimals)',
    documentation: 'https://x402.superfluid.org/',
    example: {
      steps: [
        '1. Wrap tokens to Super Token (e.g., USDC → USDCx)',
        '2. Start flow to recipient address',
        '3. Include stream proof in x-402-payment header',
        '4. Retry API request',
      ],
      headerFormat: {
        streamId: 'stream identifier',
        sender: 'your wallet address',
        flowRate: 'flow rate in wei/second',
        startTime: 'unix timestamp',
        signature: 'EIP-712 signature',
      },
    },
  };
}

/**
 * Middleware for optional x402 (allows unauthenticated but tracks payment).
 */
export function x402OptionalMiddleware(
  request: FastifyRequest,
  reply: FastifyReply,
  done: HookHandlerDoneFunction
) {
  const paymentHeader = request.headers[X402_HEADER];

  if (paymentHeader && typeof paymentHeader === 'string') {
    try {
      const proof: X402PaymentProof = JSON.parse(paymentHeader);
      verifyPayment(proof)
        .then(valid => {
          (request as any).x402Valid = valid;
          (request as any).x402Sender = valid ? proof.sender : null;
          done();
        })
        .catch(() => {
          (request as any).x402Valid = false;
          done();
        });
    } catch {
      (request as any).x402Valid = false;
      done();
    }
  } else {
    (request as any).x402Valid = false;
    done();
  }
}
