pragma solidity ^0.8.26;

import { ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { IStakingPool } from "src/interfaces/core/IStakingPool.sol";

interface IEdenFactory {

    function createChild(string memory name, string memory symbol)
        external
        returns (ISuperToken child, IStakingPool stakingPool);

}
