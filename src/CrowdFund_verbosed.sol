// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverterLibrary.sol";

contract CrowdFund {
    using PriceConverter for uint256;

    // State variables
    uint256 public constant MINIMUM_USD = 5e18; // or 5 ** 18
    uint256 private totalWithdrawn;
    address public immutable i_owner;

    struct funderData {
        address funderAddr;
        uint256 amountFunded;
    }

    funderData[] public fundersList;
    mapping(address => uint256) public addressToTotalAmountFunded;

    constructor() {
        // constructrs are functions that are imediately called when the contract is deployed
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "did not send enough ETH"
        );
        // because getConversionRate function from our library PriceConverter is set to be used with any of the uint256 values,
        // msg.vaule can call upon the getConversionRate function.
        // the msg.value is passed on as an argument to the getConversionRate function in the place of ethAmount [check the library variables].

        // require(getConversionRate(msg.value) >= minimumUsd, "didn't send enough ETH");       // default iteration
        fundersList.push(funderData(msg.sender, msg.value)); // adds senders address to the address array

        // addressToAmountFunded[msg.sender] = msg.value;
        addressToTotalAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        uint256 withdrawnAmount = address(this).balance;
        totalWithdrawn += withdrawnAmount; // Add the withdrawn amount to the totalWithdrawn

        // transfer, send & call

        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // msg.sender == address
        // // payable(msg.sender) == payable address

        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // // while transfer automatically reverts the transaction,
        // // send will only revert the transaction if we have a require statement.

        //call
        (bool callSuccess, ) = payable(msg.sender).call{value: withdrawnAmount}("");
        // call() returns (bool callSuccess, bytes memory dataReturned)

        require(callSuccess, "Call failed");
    }

    function totalWithdraw() public view returns (uint256) {
        return totalWithdrawn;
    }

    modifier onlyOwner() {
        // the modifiers are used to modify the functionality of a function.

        require(msg.sender == i_owner, "Sender is not the owner");
        _;
        // the modifier makes the function execute whatever is in the modifier first,
        // the _; in the end of the modifier suggests the function to then execute whatever is in the function later.

        // NOTE: If the _; is put on top of all other lines in the modifier, then the function will only execute the modifier after it has competed executing the contents of the function.
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}

//================================================================================================
//
// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions
//
// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

