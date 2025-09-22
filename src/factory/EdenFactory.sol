pragma solidity ^0.8.26;

/* Openzeppelin Contracts & Interfaces */

import { AccessControl } from "@openzeppelin-v5/contracts/access/AccessControl.sol";
import { SafeCast } from "@openzeppelin-v5/contracts/utils/math/SafeCast.sol";

/* Superfluid Protocol Contracts & Interfaces */
import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";
import {
    ISuperToken,
    ISuperfluidPool,
    PoolConfig
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import { IRewardController } from "src/interfaces/core/IRewardController.sol";
import { IStakingPool } from "src/interfaces/core/IStakingPool.sol";

contract EdenFactory is IEdenFactory, AccessControl {

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function createChild() external onlyRole(DEFAULT_ADMIN_ROLE) {
        // 1. create child token
        // 2. create the child staking pool
        // 3. update the reward controller configuration
    }

}
