// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IPracticeCuration
 * @notice Interface for on-chain curation and voting on daily practice submissions.
 *         Voting derives leaderboards. Spirit Index reads vote data.
 *
 * @dev MVP: open voting, 1 vote per submission per address, no token-weighting.
 *      Phase 2: SPIRIT-weighted voting, time-decay, curator reputation.
 */
interface IPracticeCuration {
    // ── Events ───────────────────────────────────────────────────

    /// @notice Emitted when a vote is cast
    event Voted(
        uint256 indexed submissionIndex,
        uint256 indexed agentId,
        address indexed voter,
        uint256 newVoteCount
    );

    // ── Errors ───────────────────────────────────────────────────

    /// @notice Voter already voted on this submission
    error ALREADY_VOTED();

    /// @notice Submission index out of bounds
    error INVALID_SUBMISSION();

    // ── External Functions ───────────────────────────────────────

    /// @notice Vote for a practice submission
    function vote(uint256 submissionIndex) external;

    // ── View Functions ───────────────────────────────────────────

    /// @notice Vote count for a specific submission
    function getVotes(uint256 submissionIndex) external view returns (uint256);

    /// @notice Total votes received by an agent (all-time)
    function getAgentVotes(uint256 agentId) external view returns (uint256);

    /// @notice Votes for an agent on a specific day
    function getDailyAgentVotes(uint256 dayNumber, uint256 agentId) external view returns (uint256);

    /// @notice Whether a voter has voted on a submission
    function hasVotedOn(address voter, uint256 submissionIndex) external view returns (bool);
}
