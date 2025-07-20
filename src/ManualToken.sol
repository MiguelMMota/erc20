// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;


contract ManualToken {
    error ManualToken__TransferAddressesMustBeDifferent();
    error ManualToken__TransferBalanceDoesntMatchInitialValue();
    error ManualToken__TransferSenderNotEnoughBalance();

    mapping(address => uint256) s_balances;

    function name() public pure returns (string memory) {
        return "Manual Token";
    }

    function totalSupply() public pure returns (uint256) {
        return 100 ether;
    }

    function decimals() public pure returns (uint256) {
        return 18;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return s_balances[owner];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        if (msg.sender != to) {
            revert ManualToken__TransferAddressesMustBeDifferent();
        }

        if (balanceOf(msg.sender) < amount) {
            revert ManualToken__TransferSenderNotEnoughBalance();
        }

        uint256 previousBalances = s_balances[msg.sender] + s_balances[to];

        s_balances[msg.sender] -= amount;
        s_balances[to] += amount;

        uint256 afterBalances = s_balances[msg.sender] + s_balances[to];

        if (previousBalances != afterBalances) {
            revert ManualToken__TransferBalanceDoesntMatchInitialValue();
        }

        return true;
    }
}