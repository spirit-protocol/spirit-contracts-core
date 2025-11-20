// SPDX-License-Identifier: AGPLv3
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

struct AirstreamConfig {
    string name;
    address token;
    bytes32 merkleRoot;
    uint96 totalAmount;
    uint64 duration;
}

struct ClaimingWindow {
    uint64 startDate;
    uint64 duration;
    address treasury;
}

struct AirstreamExtendedConfig {
    address superToken;
    ClaimingWindow claimingWindow;
    uint24 initialRewardPPM;
    uint24 feePPM;
}

interface IAirstreamFactory {

    /**
     * @notice Create a new airstream
     * @param config The configuration of the airstream
     */
    function createAirstream(AirstreamConfig memory config) external;

    /**
     * @notice Create a new airstream with extended configuration
     * @param config The configuration of the airstream
     * @param extendedConfig The extended configuration of the airstream
     */
    function createExtendedAirstream(AirstreamConfig memory config, AirstreamExtendedConfig memory extendedConfig)
        external;

}
