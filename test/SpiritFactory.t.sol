// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC721 } from "@openzeppelin-v5/contracts/token/ERC721/IERC721.sol";
import { ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import { ISpiritFactory } from "src/interfaces/factory/ISpiritFactory.sol";
import { SpiritTestBase } from "test/base/SpiritTestBase.t.sol";

import { IHooks } from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import { BalanceDelta } from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import { Currency } from "@uniswap/v4-core/src/types/Currency.sol";
import { PoolKey } from "@uniswap/v4-core/src/types/PoolKey.sol";

import { console } from "forge-std/console.sol";
import { ChildSuperToken } from "src/token/ChildSuperToken.sol";

contract SpiritFactoryTest is SpiritTestBase {

    uint160 internal constant MALICIOUS_SQRT_PRICE_X96 = 250_541_448_375_047_946_302_209_916_928;

    function setUp() public override {
        super.setUp();
    }

    function test_initialize() public view {
        assertTrue(
            _spiritFactory.hasRole(_spiritFactory.DEFAULT_ADMIN_ROLE(), ADMIN), "ADMIN does not have DEFAULT_ADMIN_ROLE"
        );
    }

    function _createChild() internal returns (ISuperToken newChildToken) {
        bytes32 salt = keccak256(abi.encode("SALT_FOR_NEW_CHILD_TOKEN"));

        vm.prank(ADMIN);
        (newChildToken,,) = _spiritFactory.createChild(
            "New Child Token", "NEWCHILD", ARTIST, AGENT, bytes32(0), salt, DEFAULT_SQRT_PRICE_X96
        );

        // State settings assertions
        assertNotEq(address(newChildToken), address(0), "Invalid child token address");

        // Token Supply Assertions
        assertEq(newChildToken.totalSupply(), _spiritFactory.CHILD_TOTAL_SUPPLY(), "Invalid minted supply");
        assertEq(
            newChildToken.balanceOf(ARTIST),
            _spiritFactory.ARTIST_ALLOCATION(),
            "Artist should not have floating CHILD tokens"
        );
        assertEq(
            newChildToken.balanceOf(AGENT),
            _spiritFactory.AGENT_ALLOCATION(),
            "Agent should not have floating CHILD tokens"
        );

        assertEq(
            newChildToken.balanceOf(address(manager)),
            _spiritFactory.DEFAULT_LIQUIDITY_SUPPLY(),
            "UniswapV4 Pool Manager should have 50M CHILD tokens (Liquidity)"
        );

        assertEq(
            newChildToken.balanceOf(address(_airstreamFactory)),
            _spiritFactory.AIRSTREAM_SUPPLY(),
            "Airstream Recipient should have 250M CHILD tokens (AIRSTREAM share)"
        );

        assertEq(
            newChildToken.balanceOf(address(ADMIN)),
            250_000_000 ether,
            "Admin should have 250M CHILD tokens (ADMIN share)"
        );

        assertEq(
            IERC721(address(positionManager)).balanceOf(address(AGENT)), 1, "AGENT should own 1 UniswapV4 Position NFT"
        );

        assertEq(_spiritFactory.spiritPool().getUnits(ARTIST), 1, "Artist pool unit shall be 1");
    }

    function test_createChild() public {
        _createChild();
    }

    function test_createChild_already_deployed() public {
        bytes32 salt1 = keccak256(abi.encode("SALT_FOR_NEW_CHILD_TOKEN_1"));

        vm.startPrank(ADMIN);
        _spiritFactory.createChild(
            "New Child Token", "NEWCHILD", ARTIST, AGENT, bytes32(0), salt1, DEFAULT_SQRT_PRICE_X96
        );

        bytes32 salt2 = keccak256(abi.encode("SALT_FOR_NEW_CHILD_TOKEN_2"));
        vm.expectRevert(ISpiritFactory.CHILD_TOKEN_ALREADY_DEPLOYED.selector);
        _spiritFactory.createChild(
            "New Child Token", "NEWCHILD", ARTIST, AGENT, bytes32(0), salt2, DEFAULT_SQRT_PRICE_X96
        );

        vm.stopPrank();
    }

    function test_createChild_invalid_caller(address nonAdmin) public {
        vm.assume(_spiritFactory.hasRole(_spiritFactory.DEFAULT_ADMIN_ROLE(), nonAdmin) != true);

        bytes32 salt = keccak256(abi.encode("SALT_FOR_NEW_CHILD_TOKEN"));

        vm.prank(nonAdmin);
        vm.expectRevert();
        _spiritFactory.createChild(
            "New Child Token", "NEWCHILD", ARTIST, AGENT, bytes32(0), salt, DEFAULT_SQRT_PRICE_X96
        );
    }

    // Simulate a malicious actor "guessing" a child token address and initializing the pool with it
    function test_createChild_invalid_poolAlreadyInitialized() public {
        bytes32 salt = keccak256(abi.encode("SALT_FOR_NEW_CHILD_TOKEN"));

        // Predict the child token address
        address predictedChildTokenAddress = _helper_predictChildTokenAddress(salt);

        // Maliciously initalize the pool with predicted child token address
        Currency currency0 = predictedChildTokenAddress < address(_spirit)
            ? Currency.wrap(address(predictedChildTokenAddress))
            : Currency.wrap(address(_spirit));
        Currency currency1 = predictedChildTokenAddress > address(_spirit)
            ? Currency.wrap(address(predictedChildTokenAddress))
            : Currency.wrap(address(_spirit));

        // Create the pool key
        PoolKey memory poolKey = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: 10_000,
            tickSpacing: 200,
            hooks: IHooks(address(0))
        });

        // Initialize the pool
        positionManager.initializePool(poolKey, MALICIOUS_SQRT_PRICE_X96);

        vm.prank(ADMIN);
        vm.expectRevert(ISpiritFactory.POOL_INITIALIZATION_FAILED.selector);
        _spiritFactory.createChild(
            "New Child Token", "NEWCHILD", ARTIST, AGENT, bytes32(0), salt, DEFAULT_SQRT_PRICE_X96
        );
    }

    function test_createChild_swapLiquidity() public {
        (ISuperToken childTokenA, ISuperToken childTokenB) = _helper_create2ChildTokens();

        dealSuperToken(TREASURY, ADMIN, _spirit, 1000 ether);

        vm.startPrank(ADMIN);
        _spirit.approve(address(swapRouter), 1000 ether);
        // Swap SPIRIT to ChildToken A
        BalanceDelta deltaA = _helper_swapSpiritForChild(address(childTokenA), 50 ether);

        // Swap SPIRIT to ChildToken B
        BalanceDelta deltaB = _helper_swapSpiritForChild(address(childTokenB), 50 ether);

        assertEq(deltaA.amount0(), deltaB.amount1());
        assertEq(deltaA.amount1(), deltaB.amount0());
        vm.stopPrank();
    }

    function _helper_create2ChildTokens() internal returns (ISuperToken childTokenA, ISuperToken childTokenB) {
        bytes32 saltA = keccak256(abi.encode("0", uint256(0)));

        vm.startPrank(ADMIN);
        (childTokenA,,) = _spiritFactory.createChild(
            "name A", "symbol A", makeAddr("ARTIST_A"), makeAddr("AGENT_A"), bytes32(0), saltA, DEFAULT_SQRT_PRICE_X96
        );

        bool tokenOrderA = address(childTokenA) < address(_spirit);
        bool tokenOrderB = address(childTokenB) < address(_spirit);

        uint256 i = 1;
        while (address(childTokenB) == address(0) || tokenOrderB == tokenOrderA) {
            bytes32 saltB = keccak256(abi.encode("i", i));

            (childTokenB,,) = _spiritFactory.createChild(
                string(abi.encode("name B", uint256(i))),
                string(abi.encode("symbol B", uint256(i))),
                makeAddr("ARTIST_B"),
                makeAddr("AGENT_B"),
                bytes32(0),
                saltB,
                DEFAULT_SQRT_PRICE_X96
            );

            tokenOrderB = address(childTokenB) < address(_spirit);
            ++i;
        }

        vm.stopPrank();
    }

    function _helper_predictChildTokenAddress(bytes32 salt) internal view returns (address predicted) {
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(_spiritFactory), salt, keccak256(type(ChildSuperToken).creationCode))
        );
        return address(uint160(uint256(hash)));
    }

    function _helper_swapSpiritForChild(address childToken, int256 amountIn) internal returns (BalanceDelta delta) {
        bool zeroForOne;
        PoolKey memory poolKey;
        if (childToken < address(_spirit)) {
            poolKey = PoolKey({
                currency0: Currency.wrap(childToken),
                currency1: Currency.wrap(address(_spirit)),
                fee: _spiritFactory.DEFAULT_POOL_FEE(),
                tickSpacing: _spiritFactory.DEFAULT_TICK_SPACING(),
                hooks: IHooks(address(0))
            });
            zeroForOne = false;
        } else {
            poolKey = PoolKey({
                currency0: Currency.wrap(address(_spirit)),
                currency1: Currency.wrap(childToken),
                fee: _spiritFactory.DEFAULT_POOL_FEE(),
                tickSpacing: _spiritFactory.DEFAULT_TICK_SPACING(),
                hooks: IHooks(address(0))
            });
            zeroForOne = true;
        }

        delta = swap(poolKey, zeroForOne, amountIn, bytes(""));
    }

}
