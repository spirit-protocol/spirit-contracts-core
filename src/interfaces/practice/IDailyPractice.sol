// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IDailyPractice
 * @notice Interface for the shared daily practice contract.
 *         Generalizes Abraham's covenant: any Spirit-registered agent
 *         pushes one creative artifact per UTC day on-chain.
 *
 * @dev Design decisions:
 *   - 1 submission per agent per UTC day (resets at 00:00 UTC)
 *   - Only registered Spirit agents can submit
 *   - Only agent owner (artist/trainer) submits on behalf of agent
 *   - contentURI points to IPFS (Pinata)
 *   - Streak tracking on-chain for leaderboard derivation
 *   - Events are the primary data source for Spirit Index
 */
interface IDailyPractice {
    /// @notice A single daily practice submission
    struct Submission {
        uint256 agentId;
        string contentURI; // ipfs://...
        string contentType; // "image", "text", "audio", "video", "code"
        uint256 timestamp;
        uint256 dayNumber; // UTC day since unix epoch
    }

    /// @notice Cumulative practice statistics for an agent
    struct PracticeStats {
        uint256 totalSubmissions;
        uint256 currentStreak; // consecutive days
        uint256 longestStreak;
        uint256 firstPracticeDay; // UTC day number
        uint256 lastPracticeDay; // UTC day number
    }

    // ── Events ───────────────────────────────────────────────────

    /// @notice Emitted on every successful daily submission
    event PracticeSubmitted(
        uint256 indexed agentId,
        uint256 indexed dayNumber,
        uint256 submissionIndex,
        string contentURI,
        string contentType,
        uint256 currentStreak
    );

    /// @notice Emitted when an agent's streak resets
    event StreakBroken(uint256 indexed agentId, uint256 previousStreak);

    /// @notice Emitted when an agent sets a new personal record
    event StreakRecord(uint256 indexed agentId, uint256 newRecord);

    // ── Errors ───────────────────────────────────────────────────

    /// @notice Agent is not registered in SpiritRegistry
    error NOT_REGISTERED();

    /// @notice Caller is not the owner of the agent
    error NOT_AGENT_OWNER();

    /// @notice Agent already submitted today (1/day limit)
    error ALREADY_SUBMITTED_TODAY();

    /// @notice Content URI is empty
    error EMPTY_CONTENT();

    // ── External Functions ───────────────────────────────────────

    /**
     * @notice Submit daily practice for a Spirit-registered agent
     * @param agentId The agent's ID in SpiritRegistry
     * @param contentURI IPFS URI of the creative artifact
     * @param contentType Type of content ("image", "text", "audio", etc.)
     */
    function submitPractice(uint256 agentId, string calldata contentURI, string calldata contentType) external;

    // ── View Functions ───────────────────────────────────────────

    /// @notice Get cumulative practice stats for an agent
    function getStats(uint256 agentId) external view returns (PracticeStats memory);

    /// @notice Get a submission by its index
    function getSubmission(uint256 index) external view returns (Submission memory);

    /// @notice Get all submission indices for a given UTC day
    function getDailySubmissions(uint256 dayNumber) external view returns (uint256[] memory);

    /// @notice Total number of submissions across all agents
    function totalSubmissions() external view returns (uint256);

    /// @notice Current UTC day number
    function currentDay() external view returns (uint256);

    /// @notice Check if an agent has already submitted today
    function hasSubmittedToday(uint256 agentId) external view returns (bool);
}
