// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ISpiritRegistry } from "../interfaces/registry/ISpiritRegistry.sol";
import { IDailyPractice } from "../interfaces/practice/IDailyPractice.sol";

/**
 * @title DailyPractice
 * @notice Shared on-chain daily practice contract for Spirit agents.
 *         Generalizes Abraham's covenant: any registered agent pushes
 *         one creative artifact per UTC day.
 *
 * @dev On-chain record of continuous creative practice.
 *      - 1 submission per agent per UTC day (block.timestamp / 86400)
 *      - Streak tracking: current, longest, total
 *      - Events are the primary data source for Spirit Index
 *      - contentURI points to IPFS; only the URI is stored on-chain
 */
contract DailyPractice is IDailyPractice {
    //      ________ __                        __
    //     / ___// //_/____  _____  __________/ /______
    //     \__ \/ __/ / ___/ / / / / ___/ __  / __/ ___/
    //    ___/ / / / / /  / /_/ / /__/ /_/ / / (__  )
    //   /____/_/ /_/_/   \__,_/\___/\__,_/_/  /____/

    /// @notice SpiritRegistry used for permission checks
    ISpiritRegistry public immutable registry;

    /// @notice All submissions (append-only log)
    Submission[] private _submissions;

    /// @notice Cumulative stats per agent
    mapping(uint256 agentId => PracticeStats) private _stats;

    /// @notice Last submission day per agent (for 1/day rate limit)
    mapping(uint256 agentId => uint256 lastDay) private _lastSubmissionDay;

    /// @notice Submission indices per UTC day
    mapping(uint256 dayNumber => uint256[]) private _dailySubmissions;

    //     ______                 __                  __
    //    / ____/___  ____  _____/ /________  _______/ /_____  _____
    //   / /   / __ \/ __ \/ ___/ __/ ___/ / / / ___/ __/ __ \/ ___/
    //  / /___/ /_/ / / / (__  ) /_/ /  / /_/ / /__/ /_/ /_/ / /
    //  \____/\____/_/ /_/____/\__/_/   \__,_/\___/\__/\____/_/

    /**
     * @param registry_ Address of the deployed SpiritRegistry
     */
    constructor(address registry_) {
        registry = ISpiritRegistry(registry_);
    }

    //      ______     __                        __   ______                 __  _
    //     / ____/  __/ /____  _________  ____ _/ /  / ____/_  ______  _____/ /_(_)___  ____  _____
    //    / __/ | |/_/ __/ _ \/ ___/ __ \/ __ `/ /  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
    //   / /____>  </ /_/  __/ /  / / / / /_/ / /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
    //  /_____/_/|_|\__/\___/_/  /_/ /_/\__,_/_/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

    /// @inheritdoc IDailyPractice
    function submitPractice(uint256 agentId, string calldata contentURI, string calldata contentType) external {
        // 1. Agent must be registered in Spirit
        if (!registry.hasSpiritAttached(agentId)) revert NOT_REGISTERED();

        // 2. Caller must be the agent owner (artist/trainer)
        if (registry.ownerOf(agentId) != msg.sender) revert NOT_AGENT_OWNER();

        // 3. Content must not be empty
        if (bytes(contentURI).length == 0) revert EMPTY_CONTENT();

        // 4. Calculate current UTC day
        uint256 today = block.timestamp / 1 days;

        // 5. Enforce 1 submission per day
        if (_lastSubmissionDay[agentId] == today) revert ALREADY_SUBMITTED_TODAY();

        // 6. Update streak
        PracticeStats storage s = _stats[agentId];
        uint256 yesterday = today - 1;

        if (s.lastPracticeDay == yesterday) {
            // Continuing streak
            s.currentStreak++;
        } else if (s.lastPracticeDay > 0 && s.lastPracticeDay < yesterday) {
            // Streak broken — missed at least one day
            emit StreakBroken(agentId, s.currentStreak);
            s.currentStreak = 1;
        } else {
            // First submission ever, or same-day edge case
            s.currentStreak = 1;
        }

        // Update longest streak
        if (s.currentStreak > s.longestStreak) {
            s.longestStreak = s.currentStreak;
            emit StreakRecord(agentId, s.longestStreak);
        }

        // First practice day
        if (s.firstPracticeDay == 0) {
            s.firstPracticeDay = today;
        }

        s.lastPracticeDay = today;
        s.totalSubmissions++;
        _lastSubmissionDay[agentId] = today;

        // 7. Store submission
        uint256 idx = _submissions.length;
        _submissions.push(
            Submission({
                agentId: agentId,
                contentURI: contentURI,
                contentType: contentType,
                timestamp: block.timestamp,
                dayNumber: today
            })
        );

        _dailySubmissions[today].push(idx);

        emit PracticeSubmitted(agentId, today, idx, contentURI, contentType, s.currentStreak);
    }

    //     _    ___                 ______                 __  _
    //    | |  / (_)__ _      __   / ____/_  ______  _____/ /_(_)___  ____  _____
    //    | | / / / _ \ | /| / /  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
    //    | |/ / /  __/ |/ |/ /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
    //    |___/_/\___/|__/|__/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

    /// @inheritdoc IDailyPractice
    function getStats(uint256 agentId) external view returns (PracticeStats memory) {
        return _stats[agentId];
    }

    /// @inheritdoc IDailyPractice
    function getSubmission(uint256 index) external view returns (Submission memory) {
        return _submissions[index];
    }

    /// @inheritdoc IDailyPractice
    function getDailySubmissions(uint256 dayNumber) external view returns (uint256[] memory) {
        return _dailySubmissions[dayNumber];
    }

    /// @inheritdoc IDailyPractice
    function totalSubmissions() external view returns (uint256) {
        return _submissions.length;
    }

    /// @inheritdoc IDailyPractice
    function currentDay() external view returns (uint256) {
        return block.timestamp / 1 days;
    }

    /// @inheritdoc IDailyPractice
    function hasSubmittedToday(uint256 agentId) external view returns (bool) {
        return _lastSubmissionDay[agentId] == block.timestamp / 1 days;
    }
}
