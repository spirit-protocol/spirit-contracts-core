// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library NetworkConfig {

    struct EdenDeploymentConfig {
        address admin;
        address treasury;
        address distributor;
        address superTokenFactory;
        string spiritTokenName;
        string spiritTokenSymbol;
        uint256 spiritTokenSupply;
    }

    function getNetworkConfig(uint256 chainId) internal pure returns (EdenDeploymentConfig memory config) {
        if (chainId == 8453) {
            config = getBaseMainnetConfig();
        } else if (chainId == 84_532) {
            config = getBaseSepoliaConfig();
        } else if (chainId == 11_155_111) {
            config = getEthereumSepoliaConfig();
        } else {
            revert("Unsupported chainId");
        }
    }

    /**
     * @dev Get Base Mainnet configuration
     */
    function getBaseMainnetConfig() internal pure returns (EdenDeploymentConfig memory) {
        return EdenDeploymentConfig({
            admin: address(0),
            treasury: address(0),
            distributor: address(0),
            superTokenFactory: 0xe20B9a38E0c96F61d1bA6b42a61512D56Fea1Eb3,
            spiritTokenName: "Spirit Token",
            spiritTokenSymbol: "SPIRIT",
            spiritTokenSupply: 1_000_000_000 ether
        });
    }

    function getLocalConfig() internal pure returns (EdenDeploymentConfig memory) {
        return getBaseMainnetConfig();
    }

    /**
     * @dev Get Base Sepolia configuration
     */
    function getBaseSepoliaConfig() internal pure returns (EdenDeploymentConfig memory) {
        return EdenDeploymentConfig({
            admin: 0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A,
            treasury: 0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A,
            distributor: 0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A,
            superTokenFactory: 0x7447E94Dfe3d804a9f46Bf12838d467c912C8F6C,
            spiritTokenName: "Secret Token",
            spiritTokenSymbol: "SECRET",
            spiritTokenSupply: 1_000_000_000 ether
        });
    }

    /**
     * @dev Get Ethereum Sepolia configuration
     */
    function getEthereumSepoliaConfig() internal pure returns (EdenDeploymentConfig memory) {
        return EdenDeploymentConfig({
            admin: 0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A,
            treasury: 0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A,
            distributor: 0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A,
            superTokenFactory: 0x254C2e152E8602839D288A7bccdf3d0974597193,
            spiritTokenName: "Secret Token",
            spiritTokenSymbol: "SECRET",
            spiritTokenSupply: 1_000_000_000 ether
        });
    }

}
