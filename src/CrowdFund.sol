// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverterLibrary.sol";

contract CrowdFund {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;
    uint256 totalWithdraw;
    address public immutable i_owner;

    struct funderData {
        address funderAddr;
        uint256 amountFunded;
    }

    funderData[] public fundersList;
    mapping(address funderAddr => uint256 amountFunded) public addressToTotalAmountFunded;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "did not send enough ETH"
        );
        fundersList.push(funderData(msg.sender, msg.value));

        addressToTotalAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        uint256 withdrawnAmount = address(this).balance;
        totalWithdraw += withdrawnAmount;

        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function totalWithdrawn() public view returns (uint256) {
        return totalWithdraw;
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Sender is not the owner");
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}

