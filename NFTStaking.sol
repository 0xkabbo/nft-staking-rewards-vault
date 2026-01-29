// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract NFTStaking is ReentrancyGuard, Ownable {
    IERC721 public immutable nftCollection;
    IERC20 public immutable rewardToken;

    uint256 public rewardRatePerHour = 10 * 10**18; // 10 tokens per hour

    struct Stake {
        uint256 tokenId;
        uint256 timestamp;
        address owner;
    }

    mapping(uint256 => Stake) public vault;

    event Staked(address indexed user, uint256 tokenId, uint256 timestamp);
    event Unstaked(address indexed user, uint256 tokenId, uint256 timestamp);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(address _nftCollection, address _rewardToken) Ownable(msg.sender) {
        nftCollection = IERC721(_nftCollection);
        rewardToken = IERC20(_rewardToken);
    }

    function stake(uint256[] calldata tokenIds) external nonReentrant {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 id = tokenIds[i];
            require(nftCollection.ownerOf(id) == msg.sender, "Not your NFT");
            
            nftCollection.transferFrom(msg.sender, address(this), id);
            
            vault[id] = Stake({
                tokenId: id,
                timestamp: block.timestamp,
                owner: msg.sender
            });

            emit Staked(msg.sender, id, block.timestamp);
        }
    }

    function calculateReward(uint256 tokenId) public view returns (uint256) {
        Stake memory deposited = vault[tokenId];
        uint256 stakedDuration = block.timestamp - deposited.timestamp;
        return (stakedDuration * rewardRatePerHour) / 3600;
    }

    function unstake(uint256[] calldata tokenIds) external nonReentrant {
        uint256 totalReward = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 id = tokenIds[i];
            Stake memory deposited = vault[id];
            require(deposited.owner == msg.sender, "Not the staker");

            totalReward += calculateReward(id);
            delete vault[id];
            
            nftCollection.transferFrom(address(this), msg.sender, id);
            emit Unstaked(msg.sender, id, block.timestamp);
        }

        if (totalReward > 0) {
            rewardToken.transfer(msg.sender, totalReward);
            emit RewardPaid(msg.sender, totalReward);
        }
    }
}
