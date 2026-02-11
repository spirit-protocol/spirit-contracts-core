// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";

import { IDailyPractice } from "src/interfaces/practice/IDailyPractice.sol";
import { IPracticeCuration } from "src/interfaces/practice/IPracticeCuration.sol";
import { DailyPractice } from "src/practice/DailyPractice.sol";
import { PracticeCuration } from "src/practice/PracticeCuration.sol";
import { SpiritRegistry } from "src/registry/SpiritRegistry.sol";

contract DailyPracticeTest is Test {
    SpiritRegistry internal registry;
    DailyPractice internal practice;
    PracticeCuration internal curation;

    address internal constant PROTOCOL_TREASURY = address(0xBEEF);
    address internal constant ARTIST_GENE = address(0xA1);
    address internal constant ARTIST_SETH = address(0xA2);
    address internal constant PLATFORM_EDEN = address(0xE1);
    address internal constant PLATFORM_OPENCLAW = address(0xC1);
    address internal constant VOTER_1 = address(0xF1);
    address internal constant VOTER_2 = address(0xF2);
    address internal constant VOTER_3 = address(0xF3);
    address internal constant RANDO = address(0xBAD);

    uint256 internal abrahamId;
    uint256 internal solienneId;

    function setUp() public {
        // Warp to a real timestamp — Forge defaults to 1, which makes day=0
        // and collides with the default 0 in the lastSubmissionDay mapping
        vm.warp(1_739_300_000); // ~Feb 11, 2025

        // Deploy registry
        registry = new SpiritRegistry(PROTOCOL_TREASURY);

        // Deploy practice contract
        practice = new DailyPractice(address(registry));

        // Deploy curation contract
        curation = new PracticeCuration(address(practice));

        // Register Abraham (Gene, Eden platform)
        address[] memory owners = new address[](0);
        vm.prank(ARTIST_GENE);
        abrahamId = registry.registerSpirit("ipfs://abraham-meta", ARTIST_GENE, PLATFORM_EDEN, owners, 1);

        // Register Solienne (Seth, OpenClaw platform)
        vm.prank(ARTIST_SETH);
        solienneId = registry.registerSpirit("ipfs://solienne-meta", ARTIST_SETH, PLATFORM_OPENCLAW, owners, 1);
    }

    // ================================================================
    //                    REGISTRATION SANITY
    // ================================================================

    function test_agentsRegistered() public view {
        assertEq(abrahamId, 1);
        assertEq(solienneId, 2);
        assertTrue(registry.hasSpiritAttached(abrahamId));
        assertTrue(registry.hasSpiritAttached(solienneId));
    }

    function test_differentPlatforms() public view {
        assertEq(registry.getSpiritConfig(abrahamId).platform, PLATFORM_EDEN);
        assertEq(registry.getSpiritConfig(solienneId).platform, PLATFORM_OPENCLAW);
    }

    // ================================================================
    //                    DAILY PRACTICE — HAPPY PATH
    // ================================================================

    function test_submitPractice() public {
        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://QmDay1Art", "image");

        assertEq(practice.totalSubmissions(), 1);

        IDailyPractice.Submission memory sub = practice.getSubmission(0);
        assertEq(sub.agentId, abrahamId);
        assertEq(sub.contentURI, "ipfs://QmDay1Art");
        assertEq(sub.contentType, "image");
        assertEq(sub.dayNumber, block.timestamp / 1 days);
    }

    function test_submitPractice_multipleAgentsSameDay() public {
        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://QmAbraham", "image");

        vm.prank(ARTIST_SETH);
        practice.submitPractice(solienneId, "ipfs://QmSolienne", "text");

        assertEq(practice.totalSubmissions(), 2);

        uint256[] memory todaySubmissions = practice.getDailySubmissions(block.timestamp / 1 days);
        assertEq(todaySubmissions.length, 2);
    }

    function test_submitPractice_allContentTypes() public {
        string[5] memory types = ["image", "text", "audio", "video", "code"];

        for (uint256 i = 0; i < 5; i++) {
            // Advance one day per iteration
            vm.warp(block.timestamp + 1 days);
            vm.prank(ARTIST_GENE);
            practice.submitPractice(abrahamId, string.concat("ipfs://Qm", types[i]), types[i]);
        }

        assertEq(practice.totalSubmissions(), 5);

        IDailyPractice.PracticeStats memory s = practice.getStats(abrahamId);
        assertEq(s.totalSubmissions, 5);
        assertEq(s.currentStreak, 5);
        assertEq(s.longestStreak, 5);
    }

    function test_hasSubmittedToday() public {
        assertFalse(practice.hasSubmittedToday(abrahamId));

        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://Qm1", "image");

        assertTrue(practice.hasSubmittedToday(abrahamId));
    }

    // ================================================================
    //                    DAILY PRACTICE — RATE LIMIT
    // ================================================================

    function test_revert_doubleSubmitSameDay() public {
        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://Qm1", "image");

        vm.prank(ARTIST_GENE);
        vm.expectRevert(IDailyPractice.ALREADY_SUBMITTED_TODAY.selector);
        practice.submitPractice(abrahamId, "ipfs://Qm2", "image");
    }

    function test_submitNextDay() public {
        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://QmDay1", "image");

        // Advance to next day
        vm.warp(block.timestamp + 1 days);

        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://QmDay2", "image");

        assertEq(practice.totalSubmissions(), 2);
    }

    // ================================================================
    //                    DAILY PRACTICE — PERMISSIONS
    // ================================================================

    function test_revert_notRegistered() public {
        uint256 fakeAgentId = 999;

        vm.prank(RANDO);
        vm.expectRevert(IDailyPractice.NOT_REGISTERED.selector);
        practice.submitPractice(fakeAgentId, "ipfs://Qm", "image");
    }

    function test_revert_notOwner() public {
        // Rando tries to submit for Abraham (owned by ARTIST_GENE)
        vm.prank(RANDO);
        vm.expectRevert(IDailyPractice.NOT_AGENT_OWNER.selector);
        practice.submitPractice(abrahamId, "ipfs://Qm", "image");
    }

    function test_revert_emptyContent() public {
        vm.prank(ARTIST_GENE);
        vm.expectRevert(IDailyPractice.EMPTY_CONTENT.selector);
        practice.submitPractice(abrahamId, "", "image");
    }

    // ================================================================
    //                    STREAK TRACKING
    // ================================================================

    function test_streak_consecutive() public {
        for (uint256 i = 0; i < 7; i++) {
            if (i > 0) vm.warp(block.timestamp + 1 days);
            vm.prank(ARTIST_GENE);
            practice.submitPractice(abrahamId, string.concat("ipfs://QmDay", vm.toString(i)), "image");
        }

        IDailyPractice.PracticeStats memory s = practice.getStats(abrahamId);
        assertEq(s.currentStreak, 7);
        assertEq(s.longestStreak, 7);
        assertEq(s.totalSubmissions, 7);
    }

    function test_streak_broken() public {
        // 3-day streak
        for (uint256 i = 0; i < 3; i++) {
            if (i > 0) vm.warp(block.timestamp + 1 days);
            vm.prank(ARTIST_GENE);
            practice.submitPractice(abrahamId, string.concat("ipfs://Qm", vm.toString(i)), "image");
        }

        IDailyPractice.PracticeStats memory s1 = practice.getStats(abrahamId);
        assertEq(s1.currentStreak, 3);

        // Skip a day (streak breaks)
        vm.warp(block.timestamp + 2 days);

        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://QmAfterBreak", "image");

        IDailyPractice.PracticeStats memory s2 = practice.getStats(abrahamId);
        assertEq(s2.currentStreak, 1); // Reset
        assertEq(s2.longestStreak, 3); // Record preserved
        assertEq(s2.totalSubmissions, 4);
    }

    function test_streak_longestPreservedAcrossMultipleBreaks() public {
        // 5-day streak
        for (uint256 i = 0; i < 5; i++) {
            if (i > 0) vm.warp(block.timestamp + 1 days);
            vm.prank(ARTIST_GENE);
            practice.submitPractice(abrahamId, string.concat("ipfs://Qm", vm.toString(i)), "image");
        }

        // Break
        vm.warp(block.timestamp + 3 days);

        // 3-day streak (shorter than record)
        for (uint256 i = 0; i < 3; i++) {
            if (i > 0) vm.warp(block.timestamp + 1 days);
            vm.prank(ARTIST_GENE);
            practice.submitPractice(abrahamId, string.concat("ipfs://QmR2_", vm.toString(i)), "image");
        }

        IDailyPractice.PracticeStats memory s = practice.getStats(abrahamId);
        assertEq(s.currentStreak, 3);
        assertEq(s.longestStreak, 5); // Still the old record
        assertEq(s.totalSubmissions, 8);
    }

    // ================================================================
    //                    STREAK EVENTS
    // ================================================================

    function test_event_streakRecord() public {
        // First submission sets longestStreak=1 (new record)
        vm.prank(ARTIST_GENE);
        // StreakRecord is emitted before PracticeSubmitted, check it comes out
        vm.expectEmit(true, false, false, true, address(practice));
        emit IDailyPractice.StreakRecord(abrahamId, 1);
        practice.submitPractice(abrahamId, "ipfs://Qm1", "image");

        // Second day — streak=2, new record
        vm.warp(block.timestamp + 1 days);
        vm.prank(ARTIST_GENE);
        vm.expectEmit(true, false, false, true, address(practice));
        emit IDailyPractice.StreakRecord(abrahamId, 2);
        practice.submitPractice(abrahamId, "ipfs://Qm2", "image");
    }

    function test_event_streakBroken() public {
        // Build a 2-day streak
        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://Qm1", "image");
        vm.warp(block.timestamp + 1 days);
        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://Qm2", "image");

        // Skip a day
        vm.warp(block.timestamp + 2 days);

        vm.prank(ARTIST_GENE);
        vm.expectEmit(true, false, false, true);
        emit IDailyPractice.StreakBroken(abrahamId, 2);
        practice.submitPractice(abrahamId, "ipfs://Qm3", "image");
    }

    // ================================================================
    //                    CURATION — HAPPY PATH
    // ================================================================

    function test_vote() public {
        // Submit art
        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://QmVotable", "image");

        // Vote
        vm.prank(VOTER_1);
        curation.vote(0);

        assertEq(curation.getVotes(0), 1);
        assertEq(curation.getAgentVotes(abrahamId), 1);
        assertTrue(curation.hasVotedOn(VOTER_1, 0));
    }

    function test_multipleVoters() public {
        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://QmPopular", "image");

        vm.prank(VOTER_1);
        curation.vote(0);

        vm.prank(VOTER_2);
        curation.vote(0);

        vm.prank(VOTER_3);
        curation.vote(0);

        assertEq(curation.getVotes(0), 3);
        assertEq(curation.getAgentVotes(abrahamId), 3);
    }

    function test_dailyAgentVotes() public {
        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://Qm", "image");

        uint256 today = block.timestamp / 1 days;

        vm.prank(VOTER_1);
        curation.vote(0);

        assertEq(curation.getDailyAgentVotes(today, abrahamId), 1);
    }

    function test_voteAcrossAgents() public {
        // Both agents submit
        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://QmA", "image");

        vm.prank(ARTIST_SETH);
        practice.submitPractice(solienneId, "ipfs://QmS", "text");

        // Voter votes for both
        vm.prank(VOTER_1);
        curation.vote(0); // Abraham

        vm.prank(VOTER_1);
        curation.vote(1); // Solienne

        assertEq(curation.getAgentVotes(abrahamId), 1);
        assertEq(curation.getAgentVotes(solienneId), 1);
    }

    // ================================================================
    //                    CURATION — ERRORS
    // ================================================================

    function test_revert_doubleVote() public {
        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://Qm", "image");

        vm.prank(VOTER_1);
        curation.vote(0);

        vm.prank(VOTER_1);
        vm.expectRevert(IPracticeCuration.ALREADY_VOTED.selector);
        curation.vote(0);
    }

    function test_revert_invalidSubmission() public {
        vm.prank(VOTER_1);
        vm.expectRevert(IPracticeCuration.INVALID_SUBMISSION.selector);
        curation.vote(999);
    }

    // ================================================================
    //                    CURATION — EVENTS
    // ================================================================

    function test_event_voted() public {
        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://Qm", "image");

        vm.prank(VOTER_1);
        vm.expectEmit(true, true, true, true);
        emit IPracticeCuration.Voted(0, abrahamId, VOTER_1, 1);
        curation.vote(0);
    }

    // ================================================================
    //                    INTEGRATION: OPENCLAW AGENTS
    // ================================================================

    function test_openclawAgentCanSubmit() public {
        // Solienne is registered with OpenClaw platform
        assertEq(registry.getSpiritConfig(solienneId).platform, PLATFORM_OPENCLAW);

        // Artist can still submit practice for OpenClaw-hosted agent
        vm.prank(ARTIST_SETH);
        practice.submitPractice(solienneId, "ipfs://QmOpenClawArt", "image");

        assertEq(practice.totalSubmissions(), 1);

        IDailyPractice.Submission memory sub = practice.getSubmission(0);
        assertEq(sub.agentId, solienneId);
    }

    function test_openclawAndEdenAgentsBothPractice() public {
        // Abraham (Eden) and Solienne (OpenClaw) both submit on same day
        vm.prank(ARTIST_GENE);
        practice.submitPractice(abrahamId, "ipfs://QmEdenArt", "image");

        vm.prank(ARTIST_SETH);
        practice.submitPractice(solienneId, "ipfs://QmClawArt", "text");

        // Both have stats
        IDailyPractice.PracticeStats memory sA = practice.getStats(abrahamId);
        IDailyPractice.PracticeStats memory sS = practice.getStats(solienneId);

        assertEq(sA.totalSubmissions, 1);
        assertEq(sS.totalSubmissions, 1);

        // Voters can compare
        vm.prank(VOTER_1);
        curation.vote(0); // Abraham

        vm.prank(VOTER_2);
        curation.vote(1); // Solienne

        // Leaderboard data
        uint256 today = block.timestamp / 1 days;
        assertEq(curation.getDailyAgentVotes(today, abrahamId), 1);
        assertEq(curation.getDailyAgentVotes(today, solienneId), 1);
    }
}
