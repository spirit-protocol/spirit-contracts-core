// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/* Superfluid Imports */
import { IVestingSchedulerV3 } from
    "@superfluid-finance/automation-contracts/scheduler/contracts/interface/IVestingSchedulerV3.sol";
import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";
import { ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

using SuperTokenV1Library for ISuperToken;

/**
 * @title SPIRIT Token Vesting Contract
 * @notice Contract holding unvested SPIRIT tokens and acting as sender for the vesting scheduler
 */
contract SpiritVesting {

    //     ______                 __                  __
    //    / ____/___  ____  _____/ /________  _______/ /_____  _____
    //   / /   / __ \/ __ \/ ___/ __/ ___/ / / / ___/ __/ __ \/ ___/
    //  / /___/ /_/ / / / (__  ) /_/ /  / /_/ / /__/ /_/ /_/ / /
    //  \____/\____/_/ /_/____/\__/_/   \__,_/\___/\__/\____/_/

    /**
     * @notice SpiritVesting contract constructor
     * @param vestingScheduler The Superfluid vesting scheduler contract
     * @param spirit The SPIRIT token contract
     * @param recipient The recipient of the vested tokens
     * @param cliffDate The timestamp when the cliff period ends and the flow can start
     * @param flowRate The rate at which tokens are streamed after the cliff period
     * @param cliffAmount The amount of tokens released at the cliff date
     * @param endDate The timestamp when the vesting schedule ends
     */
    constructor(
        IVestingSchedulerV3 vestingScheduler,
        ISuperToken spirit,
        address recipient,
        uint32 cliffDate,
        int96 flowRate,
        uint256 cliffAmount,
        uint32 endDate
    ) {
        // Grant flow and token allowances
        spirit.setMaxFlowPermissions(address(vestingScheduler));
        spirit.approve(address(vestingScheduler), type(uint256).max);

        // Create the vesting schedule for this recipient
        vestingScheduler.createVestingSchedule(
            spirit,
            recipient,
            uint32(block.timestamp),
            cliffDate,
            flowRate,
            cliffAmount,
            endDate,
            0 /* claimValidityDate */
        );
    }

}
