# DEPLOYMENT REFERENCES

## ETHEREUM SEPOLIA

### Contract Addresses

| Contract              | Contract Address                                                                                                                |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| EDEN Multisig         | [`0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A`](https://sepolia.etherscan.io/address/0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A) |
| SPIRIT Token          | [`0xbF7185a3F697eC49BA2AEC73B39bf33d8206dcF6`](https://sepolia.etherscan.io/address/0xbF7185a3F697eC49BA2AEC73B39bf33d8206dcF6) |
| Reward Controller     | [`0x44Ba05a21D65C24D614b9E3494e68a9009686303`](https://sepolia.etherscan.io/address/0x44Ba05a21D65C24D614b9E3494e68a9009686303) |
| Staking Pool (Beacon) | [`0x24b311BC2eb2cE55C2AbF34460dad134bF58c2B9`](https://sepolia.etherscan.io/address/0x24b311BC2eb2cE55C2AbF34460dad134bF58c2B9) |
| Eden Factory          | [`0x67582faf420Cb3e0eE199686aE226b846776d2bD`](https://sepolia.etherscan.io/address/0x67582faf420Cb3e0eE199686aE226b846776d2bD) |

### Logs

```shell
forge script script/Deploy.s.sol:DeployEden --rpc-url $ETH_SEPOLIA_RPC_URL --account TESTNET_DEPLOYER --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
Enter keystore password:
Script ran successfully.

== Logs ==

  ===> DEPLOYMENT CONFIGURATION
   --- Admin address         : 0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A
   --- Treasury address      : 0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A
   --- Distributor address   : 0x3139DB2845810C4DE0727A5D5Aa24146C086eE1A
   --- Super Token Factory   : 0x254C2e152E8602839D288A7bccdf3d0974597193
   --- Spirit Token Name     : Secret Token
   --- Spirit Token Symbol   : SECRET
   --- Spirit Token Supply   : 1000000000

  ===> DEPLOYING EDEN PROTOCOL
   --- Chain ID          :    11155111
   --- Deployer address  :    0x48CA32c738DC2Af6cE8bB33934fF1b59cF8B1831
   --- Deployer balance  :    10 ETH

  ===> DEPLOYMENT RESULTS
   --- Spirit Token         : 0xbF7185a3F697eC49BA2AEC73B39bf33d8206dcF6
   --- Reward Controller    : 0x44Ba05a21D65C24D614b9E3494e68a9009686303
   --- Staking Pool         : 0x24b311BC2eb2cE55C2AbF34460dad134bF58c2B9
   --- Eden Factory         : 0x67582faf420Cb3e0eE199686aE226b846776d2bD


## Setting up 1 EVM.

==========================

Chain 11155111

Estimated gas price: 0.001013092 gwei

Estimated total gas used for script: 6524739

Estimated amount required: 0.000006610160882988 ETH

==========================

##### sepolia
✅  [Success] Hash: 0x4ef9559d33d3ba67c298ff0d937ecb3cceb3b438959fb4c42be9084f68ecc9be
Contract Address: 0x67582faf420Cb3e0eE199686aE226b846776d2bD
Block: 9320117
Paid: 0.0000001822901829 ETH (181041 gas * 0.0010069 gwei)


##### sepolia
✅  [Success] Hash: 0x9e3688228f713dd6ab2f034899ec68eac2d8fedd52600de51022cbf3a6dc6afa
Contract Address: 0xbF5570d038Ed4BaDaC8a9d6B31f366334ce2547b
Block: 9320117
Paid: 0.0000007841646579 ETH (778791 gas * 0.0010069 gwei)


##### sepolia
✅  [Success] Hash: 0xf80e37e1d73a9de917530f12270b42bf9f87b655bb1e9bd37b071b49cb8c6661
Block: 9320117
Paid: 0.0000000567508978 ETH (56362 gas * 0.0010069 gwei)


##### sepolia
✅  [Success] Hash: 0x3a3082ee12eeee5e662907aec886346a0e2ca7a0507bed83c6c778c792825acb
Block: 9320117
Paid: 0.0000002680649732 ETH (266228 gas * 0.0010069 gwei)


##### sepolia
✅  [Success] Hash: 0xb49497dbb595a4935885a739b9979e2f12c25ec4ec9449fbcc896e5f6c37e2c7
Contract Address: 0xA4a6E0A7d25D1714A5064bD5fe6Ca35314977F55
Block: 9320117
Paid: 0.0000013054780708 ETH (1296532 gas * 0.0010069 gwei)


##### sepolia
✅  [Success] Hash: 0x09d2edb10387592204e81aa3023f7556d678d6b08bb029def281fd0974adf00d
Contract Address: 0x47358a9f370a4caaE5Fb3106B6e5D461e2400AE0
Block: 9320117
Paid: 0.0000015649270007 ETH (1554203 gas * 0.0010069 gwei)


##### sepolia
✅  [Success] Hash: 0xdb23207ab5f379e687ce804c0fc070495e5d69a65baf62d141bee2ddca82994c
Contract Address: 0x24b311BC2eb2cE55C2AbF34460dad134bF58c2B9
Block: 9320117
Paid: 0.0000002537780691 ETH (252039 gas * 0.0010069 gwei)


##### sepolia
✅  [Success] Hash: 0x6b510b759490283b9ccf4ef5cd2140d2d4a082463ab6e10d416b1e05d3e0be2e
Contract Address: 0x44Ba05a21D65C24D614b9E3494e68a9009686303
Block: 9320117
Paid: 0.0000002318065042 ETH (230218 gas * 0.0010069 gwei)


##### sepolia
✅  [Success] Hash: 0x48566b530d2ce9821d6ea44877eeec717d3d2fbe87f46745ea9b18e12e890371
Contract Address: 0xbF7185a3F697eC49BA2AEC73B39bf33d8206dcF6
Block: 9320117
Paid: 0.0000003496681768 ETH (347272 gas * 0.0010069 gwei)


##### sepolia
✅  [Success] Hash: 0x97bb34d3f2e72d316469ebdf3258402b5b943fde848ff4f7084dd729aed382e2
Block: 9320117
Paid: 0.0000000322570484 ETH (32036 gas * 0.0010069 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.0000050291855818 ETH (4994722 gas * avg 0.0010069 gwei)


==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

```

## BASE SEPOLIA

> TBA
