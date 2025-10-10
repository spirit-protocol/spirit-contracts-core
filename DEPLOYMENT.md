# DEPLOYMENT REFERENCES

## ETHEREUM SEPOLIA

### Contract Addresses

| Contract              | Contract Address                                                                                                                |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| EDEN Multisig         | [`0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A`](https://sepolia.etherscan.io/address/0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A) |
| SPIRIT Token          | [`0x073C97Ca5Ed16f2097A44A206193a97c0aE327A4`](https://sepolia.etherscan.io/address/0x073C97Ca5Ed16f2097A44A206193a97c0aE327A4) |
| Reward Controller     | [`0xbb44C68248fB1E108B8aaaBfA02AdE1a387c50fC`](https://sepolia.etherscan.io/address/0xbb44C68248fB1E108B8aaaBfA02AdE1a387c50fC) |
| Staking Pool (Beacon) | [`0x5a0AE4D855Fb94709032a86c0af3a42cEC855fA2`](https://sepolia.etherscan.io/address/0x5a0AE4D855Fb94709032a86c0af3a42cEC855fA2) |
| Eden Factory          | [`0x64B6A29edC6cacF9568332E302D293A562c2fb8F`](https://sepolia.etherscan.io/address/0x64B6A29edC6cacF9568332E302D293A562c2fb8F) |

### Logs

```shell
forge script script/Deploy.s.sol:DeployEden --rpc-url $ETH_SEPOLIA_RPC_URL --account TESTNET_DEPLOYER --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY

[⠊] Compiling...
No files changed, compilation skipped
Enter keystore password:
Script ran successfully.

== Logs ==

  ===> DEPLOYMENT CONFIGURATION
   --- Admin address                 : 0x5D6D8518A1d564c85ea5c41d1dc0deca70F2301C
   --- Treasury address              : 0x5D6D8518A1d564c85ea5c41d1dc0deca70F2301C
   --- Distributor address           : 0x5D6D8518A1d564c85ea5c41d1dc0deca70F2301C
   --- Super Token Factory           : 0x254C2e152E8602839D288A7bccdf3d0974597193
   --- UniswapV4 Position Manager    : 0x429ba70129df741B2Ca2a85BC3A2a3328e5c09b4
   --- UniswapV4 Pool Manager        : 0xE03A1074c86CFeDd5C142C4F04F1a1536e203543
   --- Permit2 address               : 0x000000000022D473030F116dDEE9F6B43aC78BA3
   --- Spirit Token Name             : Secret Token V2
   --- Spirit Token Symbol           : SECRETv2
   --- Spirit Token Supply           : 1000000000

  ===> DEPLOYING EDEN PROTOCOL
   --- Chain ID          :    11155111
   --- Deployer address  :    0x48CA32c738DC2Af6cE8bB33934fF1b59cF8B1831
   --- Deployer balance  :    6 ETH

  ===> DEPLOYMENT RESULTS
   --- Spirit Token         : 0x073C97Ca5Ed16f2097A44A206193a97c0aE327A4
   --- Reward Controller    : 0xbb44C68248fB1E108B8aaaBfA02AdE1a387c50fC
   --- Staking Pool         : 0x5a0AE4D855Fb94709032a86c0af3a42cEC855fA2
   --- Eden Factory         : 0x64B6A29edC6cacF9568332E302D293A562c2fb8F


## Setting up 1 EVM.

==========================

Chain 11155111

Estimated gas price: 0.001000141 gwei

Estimated total gas used for script: 9214321

Estimated amount required: 0.000009215620219261 ETH

==========================

##### sepolia
✅  [Success] Hash: 0xe3a0f1a82a771f0ddcb5a1572c67b07799df805b044f1c59de7ab60932158cd5
Block: 9382660
Paid: 0.00000004765376435 ETH (47650 gas * 0.001000079 gwei)


##### sepolia
✅  [Success] Hash: 0x6694423b8aa78e1f47813422edbef338799d7168a723a08ec18c4f3ea0b64185
Block: 9382660
Paid: 0.000000056263444461 ETH (56259 gas * 0.001000079 gwei)


##### sepolia
✅  [Success] Hash: 0x6e4b0fa2c8be935c9e119111075158adddfe71f9f0528382c29fdf267970a5a3
Block: 9382660
Paid: 0.00000067782354383 ETH (677770 gas * 0.001000079 gwei)


##### sepolia
✅  [Success] Hash: 0x420eeb74136c1e4e1779879a95d3fc8225c97c0ac43c0aa0312f49d0d00ec198
Contract Address: 0x073C97Ca5Ed16f2097A44A206193a97c0aE327A4
Block: 9382660
Paid: 0.00000033315631727 ETH (333130 gas * 0.001000079 gwei)


##### sepolia
✅  [Success] Hash: 0xbde932c2f95d0ae8edaa6d3251ca3114433b266da5b0d7edf6106b6b8ad81572
Contract Address: 0xb823C0Eec6Dc6155DE3288695eD132eC2F8e477a
Block: 9382660
Paid: 0.000001266642056818 ETH (1266542 gas * 0.001000079 gwei)


##### sepolia
✅  [Success] Hash: 0xa05d5ba059f2ab4ee0a5182e10fe335169e5984a0b9c7cb43f4d02b561e11542
Block: 9382660
Paid: 0.000000200867867308 ETH (200852 gas * 0.001000079 gwei)


##### sepolia
✅  [Success] Hash: 0x2fd12525148a5e92d6ad96a4dda785763dd1623c66a725d25f1f2a9b5f092fdb
Block: 9382660
Paid: 0.00000026588100294 ETH (265860 gas * 0.001000079 gwei)


##### sepolia
✅  [Success] Hash: 0xaedab16fade6e3c52dad24411147c34f895c1740163c65c4f985e77472b8f87c
Contract Address: 0xbb44C68248fB1E108B8aaaBfA02AdE1a387c50fC
Block: 9382660
Paid: 0.000000227730989327 ETH (227713 gas * 0.001000079 gwei)


##### sepolia
✅  [Success] Hash: 0x9550a87441fa6946928db3fbb164a1615b629b64503ea8fb1024ab0bc88fcb52
Contract Address: 0x4c08adA63009Ae92CC722a7b6510aA5bBC33c6f6
Block: 9382660
Paid: 0.000000759985034075 ETH (759925 gas * 0.001000079 gwei)


##### sepolia
✅  [Success] Hash: 0xfaa397cf7b1d9b7df2f08508c4a2fb4a1e051c74a76380266eda373bb97acd79
Block: 9382660
Paid: 0.000000051282050962 ETH (51278 gas * 0.001000079 gwei)


##### sepolia
✅  [Success] Hash: 0xb0ea5f4947600976ebbc6c31626cc5dfbbbb09464ad3bd32b4aa1540ae9d0396
Contract Address: 0x64B6A29edC6cacF9568332E302D293A562c2fb8F
Block: 9382660
Paid: 0.000000178558104976 ETH (178544 gas * 0.001000079 gwei)


##### sepolia
✅  [Success] Hash: 0xdf981d905bb15874c430bd85ca9977caf9b70d887de1f0d93aec0d7c5e1ef1ab
Contract Address: 0x5a0AE4D855Fb94709032a86c0af3a42cEC855fA2
Block: 9382660
Paid: 0.000000249360697939 ETH (249341 gas * 0.001000079 gwei)


##### sepolia
✅  [Success] Hash: 0xd9fac0ec547f8d6f6cc5045d3f29f8469be7dfd7f6df92a02c5c40ed3c30c883
Block: 9382660
Paid: 0.000000032025529817 ETH (32023 gas * 0.001000079 gwei)


##### sepolia
✅  [Success] Hash: 0xd1a0c3d9490f06a1315931b6156d7f0d36a4a919f971d3a8b3015a5c9f53d2db
Block: 9382660
Paid: 0.000000056353451571 ETH (56349 gas * 0.001000079 gwei)


##### sepolia
✅  [Success] Hash: 0xd98e1cf28c4ab2bc6fedc35c0db407d48b11028a3117370c433c9ff60ca0d98c
Contract Address: 0x81876c0f41D43CdfA9D9bee7AF037d3e41aD9FAD
Block: 9382660
Paid: 0.000002549305379216 ETH (2549104 gas * 0.001000079 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.00000695288923486 ETH (6952340 gas * avg 0.001000079 gwei)


==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
```

## BASE SEPOLIA

### Contract Addresses

| Contract              | Contract Address                                                                                                                |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| EDEN Multisig         | [`0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A`](https://sepolia.basescan.org/address/0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A) |
| SPIRIT Token          | [`0x9F44c21412B78595BAF5DB1375ee009f70fb142a`](https://sepolia.basescan.org/address/0x9F44c21412B78595BAF5DB1375ee009f70fb142a) |
| Reward Controller     | [`0xDbA19c8B040365B20aF6C377BC142f1e517f9454`](https://sepolia.basescan.org/address/0xDbA19c8B040365B20aF6C377BC142f1e517f9454) |
| Staking Pool (Beacon) | [`0x53012961598f057263Bfabf4BEb3a4fB0dd007Bb`](https://sepolia.basescan.org/address/0x53012961598f057263Bfabf4BEb3a4fB0dd007Bb) |
| Eden Factory          | [`0x6F8B2FC5f02F6904466A86C2BE49dE48b6a727a6`](https://sepolia.basescan.org/address/0x6F8B2FC5f02F6904466A86C2BE49dE48b6a727a6) |

### Logs

```shell
forge script script/Deploy.s.sol:DeployEden --rpc-url $BASE_SEPOLIA_RPC_URL --account TESTNET_DEPLOYER --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY

[⠊] Compiling...
No files changed, compilation skipped
Enter keystore password:
Script ran successfully.

== Logs ==

  ===> DEPLOYMENT CONFIGURATION
   --- Admin address                 : 0x5D6D8518A1d564c85ea5c41d1dc0deca70F2301C
   --- Treasury address              : 0x5D6D8518A1d564c85ea5c41d1dc0deca70F2301C
   --- Distributor address           : 0x5D6D8518A1d564c85ea5c41d1dc0deca70F2301C
   --- Super Token Factory           : 0x7447E94Dfe3d804a9f46Bf12838d467c912C8F6C
   --- UniswapV4 Position Manager    : 0x4B2C77d209D3405F41a037Ec6c77F7F5b8e2ca80
   --- UniswapV4 Pool Manager        : 0x05E73354cFDd6745C338b50BcFDfA3Aa6fA03408
   --- Permit2 address               : 0x000000000022D473030F116dDEE9F6B43aC78BA3
   --- Spirit Token Name             : Secret Token V2
   --- Spirit Token Symbol           : SECRETv2
   --- Spirit Token Supply           : 1000000000

  ===> DEPLOYING EDEN PROTOCOL
   --- Chain ID          :    84532
   --- Deployer address  :    0x48CA32c738DC2Af6cE8bB33934fF1b59cF8B1831
   --- Deployer balance  :    52 ETH

  ===> DEPLOYMENT RESULTS
   --- Spirit Token         : 0x9F44c21412B78595BAF5DB1375ee009f70fb142a
   --- Reward Controller    : 0xDbA19c8B040365B20aF6C377BC142f1e517f9454
   --- Staking Pool         : 0x53012961598f057263Bfabf4BEb3a4fB0dd007Bb
   --- Eden Factory         : 0x6F8B2FC5f02F6904466A86C2BE49dE48b6a727a6


## Setting up 1 EVM.

==========================

Chain 84532

Estimated gas price: 0.001000152 gwei

Estimated total gas used for script: 9205747

Estimated amount required: 0.000009207146273544 ETH

==========================

##### base-sepolia
✅  [Success] Hash: 0x98e92c6a8753699274546c81b82e54d92e8e0453b922ba759b1c2feea04b55bc
Block: 32167004
Paid: 0.000000056251331019 ETH (56247 gas * 0.001000077 gwei)


##### base-sepolia
✅  [Success] Hash: 0xb71d450adc6c443892e428e1e96c66df664f7cfe2609f975e4c570d9f05c4665
Contract Address: 0x0Cfe5ecC52Fab7D4d0fDef48dE07061a22e171d4
Block: 32167004
Paid: 0.000000759971513301 ETH (759913 gas * 0.001000077 gwei)


##### base-sepolia
✅  [Success] Hash: 0x29f629fcf0e59d8f5f6bd4f91144ee127d35e55f9f490bda3d92edfddb7946b8
Block: 32167004
Paid: 0.000000051281948406 ETH (51278 gas * 0.001000077 gwei)


##### base-sepolia
✅  [Success] Hash: 0x99c5d9a29aadafa0dc451ded655c45450ad918212a5f727359437154454e0c90
Block: 32167004
Paid: 0.000000047641668126 ETH (47638 gas * 0.001000077 gwei)


##### base-sepolia
✅  [Success] Hash: 0xfeb1c20a63dc34fd7d8245ace751676a01fc8a68cbc5a34729362c516d4041dc
Contract Address: 0x9F44c21412B78595BAF5DB1375ee009f70fb142a
Block: 32167004
Paid: 0.00000033315565101 ETH (333130 gas * 0.001000077 gwei)


##### base-sepolia
✅  [Success] Hash: 0x6060890eedd0f390835d6a36005bc1838a42fc3bdc0192c06dbb699f1d3e6279
Contract Address: 0xDbA19c8B040365B20aF6C377BC142f1e517f9454
Block: 32167004
Paid: 0.000000227730533901 ETH (227713 gas * 0.001000077 gwei)


##### base-sepolia
✅  [Success] Hash: 0xca69edbb816cf8faaaba5d1a5c488620008f4b4b9493bc731e6455020efc794b
Block: 32167004
Paid: 0.000000677798186442 ETH (677746 gas * 0.001000077 gwei)


##### base-sepolia
✅  [Success] Hash: 0xa76ad85c4db6068a44753fb99302290973c6ad2452a201e3be2fd22c2cb88645
Block: 32167004
Paid: 0.00000026588047122 ETH (265860 gas * 0.001000077 gwei)


##### base-sepolia
✅  [Success] Hash: 0xd901efcf13d465e428f100f75f907922eaaf839ea0e1b6898061de82a7358702
Contract Address: 0xC823b0E2cf91fdC5bD6B878a6a00708e6756E3E6
Block: 32167004
Paid: 0.00000126662752281 ETH (1266530 gas * 0.001000077 gwei)


##### base-sepolia
✅  [Success] Hash: 0x2bb24aec03114e42ac82d89f4e19a5702b28b0fb508797fd8a54bc1e7fafd50c
Block: 32167004
Paid: 0.000000200867465604 ETH (200852 gas * 0.001000077 gwei)


##### base-sepolia
✅  [Success] Hash: 0xb23a43c0feb6f62e625a988f9147addb5f811da365094c61f1131b4cb1ad2ff6
Contract Address: 0x6a6b267838225eE8872bE7fA563D9dF248Fb853D
Block: 32167004
Paid: 0.000002549288280084 ETH (2549092 gas * 0.001000077 gwei)


##### base-sepolia
✅  [Success] Hash: 0x1e93907307b334cdc0285d32333971aa3690efc952d6e8e7966bf3215e6e6d78
Contract Address: 0x53012961598f057263Bfabf4BEb3a4fB0dd007Bb
Block: 32167004
Paid: 0.000000249348198333 ETH (249329 gas * 0.001000077 gwei)


##### base-sepolia
✅  [Success] Hash: 0xa0889312762de01390b6bef4d575196265a412e21111e08fcebf8fe4012467fd
Block: 32167004
Paid: 0.000000056353338873 ETH (56349 gas * 0.001000077 gwei)


##### base-sepolia
✅  [Success] Hash: 0x8a4f22c9f1c89adc6e3e7e963456b51f83c0538f0f0344da7c7783092fa39598
Contract Address: 0x6F8B2FC5f02F6904466A86C2BE49dE48b6a727a6
Block: 32167004
Paid: 0.000000178557747888 ETH (178544 gas * 0.001000077 gwei)


##### base-sepolia
✅  [Success] Hash: 0x15bf984efc2741319a550f966c592cecf393252f72dbdf44ded216e1698974dc
Block: 32167004
Paid: 0.000000032025465771 ETH (32023 gas * 0.001000077 gwei)

✅ Sequence #1 on base-sepolia | Total Paid: 0.000006952779322788 ETH (6952244 gas * avg 0.001000077 gwei)


==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
```
