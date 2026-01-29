# NFT Staking Rewards Vault

This repository contains a high-performance staking system where NFT holders can earn utility tokens. It is designed for NFT collections looking to add immediate utility to their holders.

## Logic Flow


1. **Stake:** User approves the vault and deposits their NFT.
2. **Accrue:** The contract calculates rewards based on a fixed rate per block/second.
3. **Claim:** Users can claim accumulated rewards without unstaking.
4. **Unstake:** Users withdraw their NFT and receive all pending rewards.

## Security
- **ReentrancyGuard:** Protects against recursive call attacks during claims.
- **Ownership:** Only the contract owner can adjust the reward rate.
