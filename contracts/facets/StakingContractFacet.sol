// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IERC20.sol";

contract StakingContractFacet {
    error NOT_TIME_FOR_WITHDRAWAL();
    error NOT_AUTHORISED_TO_CALL_FUNCTION();
    error ZERO_VALUE();
    error UNLOCKTIME_SHOULD_BE_FUTURE();
    error DONT_HAVE_ENOUGH_FUNDS();
    error NO_STAKE_NO_REWARD();

    uint256 public unlockTime;
    address public owner;
    IERC20 public stakeToken;
    IERC20 public rewardToken;

    event WithdrawalSuccessful(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed balance,
        uint256 when
    );
    event DepositSuccessful(address indexed user, uint256 indexed amount);
    event RewardAmount(address indexed user, uint256 indexed amount);

    mapping(address => uint) public stakers;
    mapping(address => uint256) public stakeTime;
    mapping(address => uint256) public rewards;

    constructor(uint _unlockTime, address _stakeToken, address _rewardToken) {
        if (block.timestamp > _unlockTime) {
            revert UNLOCKTIME_SHOULD_BE_FUTURE();
        }

        unlockTime = _unlockTime;
        owner = msg.sender;
        stakeToken = IERC20(_stakeToken);
        rewardToken = IERC20(_rewardToken);
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, "ZERO_VALUE");

        stakeToken.transferFrom(msg.sender, address(this), _amount);
        stakeTime[msg.sender] = block.timestamp;
        stakers[msg.sender] = stakers[msg.sender] + _amount;
        emit DepositSuccessful(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(block.timestamp >= unlockTime, "NOT_TIME_FOR_WITHDRAWAL");
        uint256 _userStakedBal = stakers[msg.sender];
        require(_userStakedBal > 0, "DONT_HAVE_ENOUGH_FUNDS");

        uint256 elapsedTime = block.timestamp - stakeTime[msg.sender];
        uint256 reward = (_userStakedBal * elapsedTime) / (365 days * 100);

        stakers[msg.sender] = _userStakedBal + reward;
        stakers[msg.sender] = stakers[msg.sender] - _amount;
        rewards[msg.sender] = reward;

        stakeToken.transfer(msg.sender, _amount);
        rewardToken.transfer(msg.sender, reward);
        emit WithdrawalSuccessful(
            msg.sender,
            _amount,
            _userStakedBal,
            block.timestamp
        );
    }

    function checkReward() external view returns (uint256) {
        uint256 _userStakedBal = stakers[msg.sender];
        require(_userStakedBal > 0, "NO_STAKE_NO_REWARD");

        uint256 elapsedTime = block.timestamp - stakeTime[msg.sender];
        uint256 reward = (_userStakedBal * elapsedTime) / (365 days * 100); // Assuming 120% APY

        return rewards[msg.sender] + reward;
    }

    function checkContractBalance() external view returns (uint) {
        return stakeToken.balanceOf(address(this));
    }
}
