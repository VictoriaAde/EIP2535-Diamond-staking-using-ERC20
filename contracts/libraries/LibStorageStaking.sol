// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IERC20.sol";

library LibStorageStaking {
    struct StakingStorage {
        uint256 unlockTime;
        address owner;
        IERC20 stakeToken;
        IERC20 rewardToken;
        mapping(address => uint) stakers;
        mapping(address => uint256) stakeTime;
        mapping(address => uint256) rewards;
    }

    bytes32 constant STORAGE_POSITION =
        keccak256("diamond.standard.staking.storage");

    function stakingStorage()
        internal
        pure
        returns (StakingStorage storage ss)
    {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ss.slot := position
        }
    }

    function setUnlockTime(uint256 _unlockTime) internal {
        stakingStorage().unlockTime = _unlockTime;
    }

    function setOwner(address _owner) internal {
        stakingStorage().owner = _owner;
    }

    function setStakeToken(IERC20 _stakeToken) internal {
        stakingStorage().stakeToken = _stakeToken;
    }

    function setRewardToken(IERC20 _rewardToken) internal {
        stakingStorage().rewardToken = _rewardToken;
    }

    function setStaker(address _staker, uint _amount) internal {
        stakingStorage().stakers[_staker] = _amount;
    }

    function setStakeTime(address _staker, uint256 _timestamp) internal {
        stakingStorage().stakeTime[_staker] = _timestamp;
    }

    function setReward(address _staker, uint256 _reward) internal {
        stakingStorage().rewards[_staker] = _reward;
    }

    function getUnlockTime() internal view returns (uint256) {
        return stakingStorage().unlockTime;
    }

    function getOwner() internal view returns (address) {
        return stakingStorage().owner;
    }

    function getStakeToken() internal view returns (IERC20) {
        return stakingStorage().stakeToken;
    }

    function getRewardToken() internal view returns (IERC20) {
        return stakingStorage().rewardToken;
    }

    function getStaker(address _staker) internal view returns (uint) {
        return stakingStorage().stakers[_staker];
    }

    function getStakeTime(address _staker) internal view returns (uint256) {
        return stakingStorage().stakeTime[_staker];
    }

    function getReward(address _staker) internal view returns (uint256) {
        return stakingStorage().rewards[_staker];
    }
}
