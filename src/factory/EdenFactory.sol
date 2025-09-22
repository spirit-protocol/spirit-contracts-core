pragma solidity ^0.8.26;

/* Openzeppelin Imports */
import { AccessControl } from "@openzeppelin-v5/contracts/access/AccessControl.sol";
import { Clones } from "@openzeppelin-v5/contracts/proxy/Clones.sol";

/* Superfluid Imports */
import { ISuperTokenFactory } from
    "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperTokenFactory.sol";
import { ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

/* Local Imports */
import { IRewardController } from "src/interfaces/core/IRewardController.sol";
import { IStakingPool } from "src/interfaces/core/IStakingPool.sol";
import { IEdenFactory } from "src/interfaces/factory/IEdenFactory.sol";
import { IChildSuperToken } from "src/interfaces/token/IChildSuperToken.sol";
import { ChildSuperToken } from "src/token/ChildSuperToken.sol";

using Clones for address;

contract EdenFactory is IEdenFactory, AccessControl {

    address public immutable STAKING_POOL_IMPLEMENTATION;
    ISuperTokenFactory public immutable SUPER_TOKEN_FACTORY;
    IRewardController public immutable REWARD_CONTROLLER;

    uint256 public constant DEFAULT_SUPPLY = 1_000_000_000 ether;

    constructor(
        address admin,
        address _stakingPoolImplementation,
        IRewardController _rewardController,
        ISuperTokenFactory _superTokenFactory
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);

        STAKING_POOL_IMPLEMENTATION = _stakingPoolImplementation;
        REWARD_CONTROLLER = _rewardController;
        SUPER_TOKEN_FACTORY = _superTokenFactory;
    }

    function createChild(string memory name, string memory symbol)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (ISuperToken child, IStakingPool stakingPool)
    {
        // deploy the new child token with default 1B supply to the caller (admin)
        child = ISuperToken(_deployToken(name, symbol, DEFAULT_SUPPLY, msg.sender));

        // Deploy a new StakingPool contract associated to the child token
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, address(child)));
        address instance = STAKING_POOL_IMPLEMENTATION.cloneDeterministic(salt);

        stakingPool = IStakingPool(instance);

        // Initialize the StakingPool proxy contract
        stakingPool.initialize(child);

        // 3. update the reward controller configuration
        REWARD_CONTROLLER.setStakingPool(address(child), stakingPool);
    }

    function _deployToken(string memory name, string memory symbol, uint256 supply, address recipient)
        internal
        returns (address childToken)
    {
        // This salt will prevent token with the same name and symbol from being deployed twice
        bytes32 salt = keccak256(abi.encode(name, symbol));
        childToken = address(new ChildSuperToken{ salt: salt }());

        IChildSuperToken(childToken).initialize(SUPER_TOKEN_FACTORY, name, symbol, recipient, supply);
    }

}
