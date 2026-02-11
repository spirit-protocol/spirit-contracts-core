// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IDailyPractice } from "../interfaces/practice/IDailyPractice.sol";
import { IPracticeCuration } from "../interfaces/practice/IPracticeCuration.sol";

/**
 * @title PracticeCuration
 * @notice On-chain curation and voting on daily practice submissions.
 *         Any address can vote once per submission. Votes derive leaderboards.
 *         Spirit Index reads vote counts for agent scoring.
 *
 * @dev MVP: open voting (1 address = 1 vote, no token-weighting).
 *      Phase 2 additions:
 *        - SPIRIT-weighted voting (stake-to-curate)
 *        - Time-decay on votes
 *        - Curator reputation scores
 */
contract PracticeCuration is IPracticeCuration {
    //      ________ __                        __
    //     / ___// //_/____  _____  __________/ /______
    //     \__ \/ __/ / ___/ / / / / ___/ __  / __/ ___/
    //    ___/ / / / / /  / /_/ / /__/ /_/ / / (__  )
    //   /____/_/ /_/_/   \__,_/\___/\__,_/_/  /____/

    /// @notice Reference to the DailyPractice contract
    IDailyPractice public immutable practice;

    /// @notice Vote count per submission index
    mapping(uint256 submissionIndex => uint256 voteCount) private _votes;

    /// @notice Total votes received per agent (all-time)
    mapping(uint256 agentId => uint256 totalVotes) private _agentVotes;

    /// @notice Whether voter has voted on a specific submission
    mapping(address voter => mapping(uint256 submissionIndex => bool voted)) private _hasVoted;

    /// @notice Daily vote totals per agent
    mapping(uint256 dayNumber => mapping(uint256 agentId => uint256 votes)) private _dailyAgentVotes;

    //     ______                 __                  __
    //    / ____/___  ____  _____/ /________  _______/ /_____  _____
    //   / /   / __ \/ __ \/ ___/ __/ ___/ / / / ___/ __/ __ \/ ___/
    //  / /___/ /_/ / / / (__  ) /_/ /  / /_/ / /__/ /_/ /_/ / /
    //  \____/\____/_/ /_/____/\__/_/   \__,_/\___/\__/\____/_/

    /**
     * @param practice_ Address of the deployed DailyPractice contract
     */
    constructor(address practice_) {
        practice = IDailyPractice(practice_);
    }

    //      ______     __                        __   ______                 __  _
    //     / ____/  __/ /____  _________  ____ _/ /  / ____/_  ______  _____/ /_(_)___  ____  _____
    //    / __/ | |/_/ __/ _ \/ ___/ __ \/ __ `/ /  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
    //   / /____>  </ /_/  __/ /  / / / / /_/ / /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
    //  /_____/_/|_|\__/\___/_/  /_/ /_/\__,_/_/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

    /// @inheritdoc IPracticeCuration
    function vote(uint256 submissionIndex) external {
        // Validate submission exists
        if (submissionIndex >= practice.totalSubmissions()) revert INVALID_SUBMISSION();

        // Prevent double voting
        if (_hasVoted[msg.sender][submissionIndex]) revert ALREADY_VOTED();

        _hasVoted[msg.sender][submissionIndex] = true;

        // Read the submission to get agentId and dayNumber
        IDailyPractice.Submission memory sub = practice.getSubmission(submissionIndex);

        // Increment counters
        _votes[submissionIndex]++;
        _agentVotes[sub.agentId]++;
        _dailyAgentVotes[sub.dayNumber][sub.agentId]++;

        emit Voted(submissionIndex, sub.agentId, msg.sender, _votes[submissionIndex]);
    }

    //     _    ___                 ______                 __  _
    //    | |  / (_)__ _      __   / ____/_  ______  _____/ /_(_)___  ____  _____
    //    | | / / / _ \ | /| / /  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
    //    | |/ / /  __/ |/ |/ /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
    //    |___/_/\___/|__/|__/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

    /// @inheritdoc IPracticeCuration
    function getVotes(uint256 submissionIndex) external view returns (uint256) {
        return _votes[submissionIndex];
    }

    /// @inheritdoc IPracticeCuration
    function getAgentVotes(uint256 agentId) external view returns (uint256) {
        return _agentVotes[agentId];
    }

    /// @inheritdoc IPracticeCuration
    function getDailyAgentVotes(uint256 dayNumber, uint256 agentId) external view returns (uint256) {
        return _dailyAgentVotes[dayNumber][agentId];
    }

    /// @inheritdoc IPracticeCuration
    function hasVotedOn(address voter, uint256 submissionIndex) external view returns (bool) {
        return _hasVoted[voter][submissionIndex];
    }
}
