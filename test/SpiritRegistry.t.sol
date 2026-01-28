// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";

import { IERC20 } from "@openzeppelin-v5/contracts/token/ERC20/IERC20.sol";
import { ERC20 } from "@openzeppelin-v5/contracts/token/ERC20/ERC20.sol";

import { IERC8004IdentityRegistry } from "src/interfaces/registry/IERC8004IdentityRegistry.sol";
import { ISpiritRegistry } from "src/interfaces/registry/ISpiritRegistry.sol";
import { ERC8004IdentityRegistry } from "src/registry/ERC8004IdentityRegistry.sol";
import { SpiritRegistry } from "src/registry/SpiritRegistry.sol";

/// @dev Minimal mock ERC-20 for revenue routing tests
contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MOCK") {
        _mint(msg.sender, 1_000_000 ether);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

/// @dev Mock external ERC-8004 registry for attachSpirit tests
contract MockExternalRegistry is ERC8004IdentityRegistry {
    constructor() ERC8004IdentityRegistry("External Registry", "EXT-ID") { }
}

contract SpiritRegistryTest is Test {
    SpiritRegistry internal registry;
    MockERC20 internal mockToken;
    MockExternalRegistry internal externalRegistry;

    address internal constant PROTOCOL_TREASURY = address(0xBEEF);
    address internal constant ARTIST = address(0xA1);
    address internal constant PLATFORM = address(0xA2);
    address internal constant OTHER = address(0xA3);

    // EIP-712 typehash (must match contract)
    bytes32 internal constant AGENT_WALLET_TYPEHASH =
        keccak256("SetAgentWallet(uint256 agentId,address newWallet,uint256 deadline)");

    function setUp() public {
        registry = new SpiritRegistry(PROTOCOL_TREASURY);
        mockToken = new MockERC20();
        externalRegistry = new MockExternalRegistry();
    }

    // ============================================================
    //                    ERC-8004 BASE TESTS
    // ============================================================

    function test_register_withURIAndMetadata() public {
        IERC8004IdentityRegistry.MetadataEntry[] memory meta = new IERC8004IdentityRegistry.MetadataEntry[](2);
        meta[0] = IERC8004IdentityRegistry.MetadataEntry("name", "Abraham");
        meta[1] = IERC8004IdentityRegistry.MetadataEntry("type", "artist-agent");

        vm.prank(ARTIST);
        uint256 agentId = registry.register("ipfs://Qm123", meta);

        assertEq(agentId, 1);
        assertEq(registry.ownerOf(agentId), ARTIST);
        assertEq(registry.agentURI(agentId), "ipfs://Qm123");
        assertEq(registry.getMetadata(agentId, "name"), "Abraham");
        assertEq(registry.getMetadata(agentId, "type"), "artist-agent");
        assertTrue(registry.exists(agentId));
    }

    function test_register_withURIOnly() public {
        vm.prank(ARTIST);
        uint256 agentId = registry.register("ipfs://Qm456");

        assertEq(agentId, 1);
        assertEq(registry.ownerOf(agentId), ARTIST);
        assertEq(registry.agentURI(agentId), "ipfs://Qm456");
    }

    function test_register_bare() public {
        vm.prank(ARTIST);
        uint256 agentId = registry.register();

        assertEq(agentId, 1);
        assertEq(registry.ownerOf(agentId), ARTIST);
        assertEq(registry.agentURI(agentId), "");
    }

    function test_register_autoIncrements() public {
        vm.startPrank(ARTIST);
        uint256 id1 = registry.register();
        uint256 id2 = registry.register();
        uint256 id3 = registry.register();
        vm.stopPrank();

        assertEq(id1, 1);
        assertEq(id2, 2);
        assertEq(id3, 3);
    }

    function test_setAgentURI() public {
        vm.prank(ARTIST);
        uint256 agentId = registry.register("ipfs://old");

        vm.prank(ARTIST);
        registry.setAgentURI(agentId, "ipfs://new");

        assertEq(registry.agentURI(agentId), "ipfs://new");
    }

    function test_setAgentURI_revert_notOwner() public {
        vm.prank(ARTIST);
        uint256 agentId = registry.register("ipfs://test");

        vm.prank(OTHER);
        vm.expectRevert(IERC8004IdentityRegistry.NOT_OWNER.selector);
        registry.setAgentURI(agentId, "ipfs://hack");
    }

    function test_setAgentWallet_withEIP712() public {
        vm.prank(ARTIST);
        uint256 agentId = registry.register("ipfs://test");

        // Create a new wallet with known private key
        uint256 walletKey = 0xBEEF;
        address newWallet = vm.addr(walletKey);
        uint256 deadline = block.timestamp + 1 hours;

        // Build EIP-712 digest
        bytes32 structHash = keccak256(abi.encode(AGENT_WALLET_TYPEHASH, agentId, newWallet, deadline));
        bytes32 domainSeparator = registry.DOMAIN_SEPARATOR();
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(walletKey, digest);
        bytes memory sig = abi.encodePacked(r, s, v);

        vm.prank(ARTIST);
        registry.setAgentWallet(agentId, newWallet, deadline, sig);

        assertEq(registry.agentWalletOf(agentId), newWallet);
    }

    function test_setAgentWallet_revert_expired() public {
        vm.prank(ARTIST);
        uint256 agentId = registry.register();

        uint256 walletKey = 0xBEEF;
        address newWallet = vm.addr(walletKey);
        uint256 deadline = block.timestamp - 1; // expired

        bytes32 structHash = keccak256(abi.encode(AGENT_WALLET_TYPEHASH, agentId, newWallet, deadline));
        bytes32 domainSeparator = registry.DOMAIN_SEPARATOR();
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(walletKey, digest);
        bytes memory sig = abi.encodePacked(r, s, v);

        vm.prank(ARTIST);
        vm.expectRevert(IERC8004IdentityRegistry.DEADLINE_EXPIRED.selector);
        registry.setAgentWallet(agentId, newWallet, deadline, sig);
    }

    function test_setAgentWallet_revert_invalidSignature() public {
        vm.prank(ARTIST);
        uint256 agentId = registry.register();

        uint256 walletKey = 0xBEEF;
        address newWallet = vm.addr(walletKey);
        uint256 deadline = block.timestamp + 1 hours;

        // Sign with wrong key
        uint256 wrongKey = 0xDEAD;
        bytes32 structHash = keccak256(abi.encode(AGENT_WALLET_TYPEHASH, agentId, newWallet, deadline));
        bytes32 domainSeparator = registry.DOMAIN_SEPARATOR();
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(wrongKey, digest);
        bytes memory sig = abi.encodePacked(r, s, v);

        vm.prank(ARTIST);
        vm.expectRevert(IERC8004IdentityRegistry.INVALID_SIGNATURE.selector);
        registry.setAgentWallet(agentId, newWallet, deadline, sig);
    }

    function test_setMetadata() public {
        vm.prank(ARTIST);
        uint256 agentId = registry.register();

        vm.prank(ARTIST);
        registry.setMetadata(agentId, "spirit:platform", "eden");

        assertEq(registry.getMetadata(agentId, "spirit:platform"), "eden");
    }

    function test_setMetadata_revert_notOwner() public {
        vm.prank(ARTIST);
        uint256 agentId = registry.register();

        vm.prank(OTHER);
        vm.expectRevert(IERC8004IdentityRegistry.NOT_OWNER.selector);
        registry.setMetadata(agentId, "key", "value");
    }

    function test_exists_false() public view {
        assertFalse(registry.exists(999));
    }

    // ============================================================
    //                    SPIRIT EXTENSION TESTS
    // ============================================================

    function test_registerSpirit() public {
        address[] memory owners = new address[](2);
        owners[0] = ARTIST;
        owners[1] = PLATFORM;

        vm.prank(address(this));
        uint256 agentId = registry.registerSpirit("ipfs://abraham", ARTIST, PLATFORM, owners, 2);

        assertEq(agentId, 1);
        assertEq(registry.ownerOf(agentId), ARTIST);
        assertEq(registry.agentURI(agentId), "ipfs://abraham");
        assertEq(registry.agentWalletOf(agentId), ARTIST);
        assertTrue(registry.hasSpiritAttached(agentId));

        ISpiritRegistry.SpiritConfig memory config = registry.getSpiritConfig(agentId);
        assertEq(config.treasury, ARTIST);
        assertEq(config.artist, ARTIST);
        assertEq(config.platform, PLATFORM);
        assertEq(config.createdAt, block.timestamp);
        assertFalse(config.hasToken);
    }

    function test_registerSpirit_defaultRevenueConfig() public {
        address[] memory owners = new address[](1);
        owners[0] = ARTIST;

        uint256 agentId = registry.registerSpirit("ipfs://test", ARTIST, PLATFORM, owners, 1);

        ISpiritRegistry.RevenueConfig memory rev = registry.getRevenueConfig(agentId);
        assertEq(rev.artistBps, 2500);
        assertEq(rev.agentBps, 2500);
        assertEq(rev.platformBps, 2500);
        assertEq(rev.protocolBps, 2500);
    }

    function test_routeRevenue_ETH() public {
        address[] memory owners = new address[](1);
        owners[0] = ARTIST;
        uint256 agentId = registry.registerSpirit("ipfs://test", ARTIST, PLATFORM, owners, 1);

        // Fund the test contract
        vm.deal(address(this), 1 ether);

        uint256 artistBefore = ARTIST.balance;
        uint256 platformBefore = PLATFORM.balance;
        uint256 treasuryBefore = PROTOCOL_TREASURY.balance;

        registry.routeRevenue{ value: 1 ether }(agentId, address(0), 0);

        // 25% each = 0.25 ether
        assertEq(ARTIST.balance - artistBefore, 0.5 ether); // artist + agent (treasury == artist in this config)
        assertEq(PLATFORM.balance - platformBefore, 0.25 ether);
        assertEq(PROTOCOL_TREASURY.balance - treasuryBefore, 0.25 ether);
    }

    function test_routeRevenue_ERC20() public {
        address[] memory owners = new address[](1);
        owners[0] = ARTIST;
        uint256 agentId = registry.registerSpirit("ipfs://test", ARTIST, PLATFORM, owners, 1);

        uint256 amount = 10_000 ether;
        mockToken.mint(address(this), amount);
        mockToken.approve(address(registry), amount);

        registry.routeRevenue(agentId, address(mockToken), amount);

        // 25% each = 2500 ether
        assertEq(mockToken.balanceOf(ARTIST), 5000 ether); // artist + agent share (same address)
        assertEq(mockToken.balanceOf(PLATFORM), 2500 ether);
        assertEq(mockToken.balanceOf(PROTOCOL_TREASURY), 2500 ether);
    }

    function test_routeRevenue_revert_noETH() public {
        address[] memory owners = new address[](1);
        owners[0] = ARTIST;
        uint256 agentId = registry.registerSpirit("ipfs://test", ARTIST, PLATFORM, owners, 1);

        vm.expectRevert(SpiritRegistry.NO_ETH_SENT.selector);
        registry.routeRevenue(agentId, address(0), 0);
    }

    function test_routeRevenue_revert_ethWithERC20() public {
        address[] memory owners = new address[](1);
        owners[0] = ARTIST;
        uint256 agentId = registry.registerSpirit("ipfs://test", ARTIST, PLATFORM, owners, 1);

        vm.deal(address(this), 1 ether);
        vm.expectRevert(SpiritRegistry.ETH_WITH_ERC20.selector);
        registry.routeRevenue{ value: 1 ether }(agentId, address(mockToken), 1000);
    }

    function test_routeRevenue_revert_spiritNotAttached() public {
        // Register a plain ERC-8004 agent (no Spirit)
        vm.prank(ARTIST);
        uint256 agentId = registry.register("ipfs://plain");

        vm.deal(address(this), 1 ether);
        vm.expectRevert(ISpiritRegistry.SPIRIT_NOT_ATTACHED.selector);
        registry.routeRevenue{ value: 1 ether }(agentId, address(0), 0);
    }

    function test_setRevenueConfig() public {
        address[] memory owners = new address[](1);
        owners[0] = ARTIST;
        uint256 agentId = registry.registerSpirit("ipfs://test", ARTIST, PLATFORM, owners, 1);

        ISpiritRegistry.RevenueConfig memory newConfig =
            ISpiritRegistry.RevenueConfig({ artistBps: 5000, agentBps: 2000, platformBps: 2000, protocolBps: 1000 });

        vm.prank(ARTIST);
        registry.setRevenueConfig(agentId, newConfig);

        ISpiritRegistry.RevenueConfig memory stored = registry.getRevenueConfig(agentId);
        assertEq(stored.artistBps, 5000);
        assertEq(stored.agentBps, 2000);
        assertEq(stored.platformBps, 2000);
        assertEq(stored.protocolBps, 1000);
    }

    function test_setRevenueConfig_revert_invalidSum() public {
        address[] memory owners = new address[](1);
        owners[0] = ARTIST;
        uint256 agentId = registry.registerSpirit("ipfs://test", ARTIST, PLATFORM, owners, 1);

        ISpiritRegistry.RevenueConfig memory badConfig =
            ISpiritRegistry.RevenueConfig({ artistBps: 5000, agentBps: 5000, platformBps: 5000, protocolBps: 5000 });

        vm.prank(ARTIST);
        vm.expectRevert(ISpiritRegistry.INVALID_REVENUE_CONFIG.selector);
        registry.setRevenueConfig(agentId, badConfig);
    }

    function test_setRevenueConfig_revert_notOwner() public {
        address[] memory owners = new address[](1);
        owners[0] = ARTIST;
        uint256 agentId = registry.registerSpirit("ipfs://test", ARTIST, PLATFORM, owners, 1);

        ISpiritRegistry.RevenueConfig memory config =
            ISpiritRegistry.RevenueConfig({ artistBps: 2500, agentBps: 2500, platformBps: 2500, protocolBps: 2500 });

        vm.prank(OTHER);
        vm.expectRevert(IERC8004IdentityRegistry.NOT_OWNER.selector);
        registry.setRevenueConfig(agentId, config);
    }

    function test_updateTreasury() public {
        address[] memory owners = new address[](1);
        owners[0] = ARTIST;
        uint256 agentId = registry.registerSpirit("ipfs://test", ARTIST, PLATFORM, owners, 1);

        address newTreasury = address(0xBEE2);
        vm.prank(ARTIST); // artist == treasury in this setup
        registry.updateTreasury(agentId, newTreasury);

        assertEq(registry.getTreasury(agentId), newTreasury);
        assertEq(registry.agentWalletOf(agentId), newTreasury);
    }

    function test_updateTreasury_revert_notTreasury() public {
        address[] memory owners = new address[](1);
        owners[0] = ARTIST;
        uint256 agentId = registry.registerSpirit("ipfs://test", ARTIST, PLATFORM, owners, 1);

        vm.prank(OTHER);
        vm.expectRevert(SpiritRegistry.NOT_TREASURY.selector);
        registry.updateTreasury(agentId, address(0xBEE2));
    }

    function test_attachSpirit() public {
        // Register an agent in the external registry
        vm.prank(ARTIST);
        uint256 externalId = externalRegistry.register("ipfs://external");

        // Attach Spirit economics
        vm.prank(ARTIST);
        uint256 spiritId = registry.attachSpirit(address(externalRegistry), externalId, ARTIST, PLATFORM);

        assertTrue(registry.hasSpiritAttached(spiritId));

        ISpiritRegistry.ExternalAgent memory ext = registry.getExternalAgent(spiritId);
        assertEq(ext.registry, address(externalRegistry));
        assertEq(ext.agentId, externalId);

        ISpiritRegistry.SpiritConfig memory config = registry.getSpiritConfig(spiritId);
        assertEq(config.artist, ARTIST);
        assertEq(config.platform, PLATFORM);
    }

    function test_attachSpirit_revert_notOwner() public {
        vm.prank(ARTIST);
        uint256 externalId = externalRegistry.register("ipfs://external");

        vm.prank(OTHER); // OTHER doesn't own the external agent
        vm.expectRevert(ISpiritRegistry.EXTERNAL_VERIFICATION_FAILED.selector);
        registry.attachSpirit(address(externalRegistry), externalId, OTHER, PLATFORM);
    }

    function test_createChildToken_revert_notImplemented() public {
        address[] memory owners = new address[](1);
        owners[0] = ARTIST;
        uint256 agentId = registry.registerSpirit("ipfs://test", ARTIST, PLATFORM, owners, 1);

        vm.prank(ARTIST);
        vm.expectRevert(SpiritRegistry.NOT_IMPLEMENTED.selector);
        registry.createChildToken(agentId, "Test", "TST", bytes32(0), 0);
    }

    function test_protocolTreasury() public view {
        assertEq(registry.protocolTreasury(), PROTOCOL_TREASURY);
    }

    function test_defaultRevenueConfig() public view {
        ISpiritRegistry.RevenueConfig memory def = registry.defaultRevenueConfig();
        assertEq(def.artistBps, 2500);
        assertEq(def.agentBps, 2500);
        assertEq(def.platformBps, 2500);
        assertEq(def.protocolBps, 2500);
    }

    function test_getChildToken_defaultZero() public {
        address[] memory owners = new address[](1);
        owners[0] = ARTIST;
        uint256 agentId = registry.registerSpirit("ipfs://test", ARTIST, PLATFORM, owners, 1);

        assertEq(registry.getChildToken(agentId), address(0));
    }

    function test_getStakingPool_defaultZero() public {
        address[] memory owners = new address[](1);
        owners[0] = ARTIST;
        uint256 agentId = registry.registerSpirit("ipfs://test", ARTIST, PLATFORM, owners, 1);

        assertEq(registry.getStakingPool(agentId), address(0));
    }

    // Allow this contract to receive ETH (for testing)
    receive() external payable { }
}
