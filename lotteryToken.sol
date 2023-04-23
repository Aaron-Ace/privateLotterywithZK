// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    address owner;
    uint256 value;
    constructor(address prizeAddr,uint256 _value) ERC20("Gold", "GLD") {
        owner=payable(prizeAddr);
        value=_value;
    }

    function givePrize(address winner) public{
        require(msh.sender==owner,"only the owner can do it");
        _mint(msg.sender,1);
        transfer(winner, amount);
    }

    function  burnPrize(uint256 amount,address winner){
        require(owner==msg.sender,"only the owner can do it");
        _burn(winner, amount);
    }

    function checkPrize() public view{
        return value;
    }
}