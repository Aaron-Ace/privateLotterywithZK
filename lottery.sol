// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface Iprize{
    function deposit(bytes32 _commitment) external payable;        
}

contract Lottery {
    address owner;  //the owner of the contract

    uint256 number;
    address[] prizeAddr;  //the address for accepting prize
    uint8[] prize;  //the prize
    uint8[] probability;  //the probability of the contract

    constructor(address[] memory _prizeAddr, uint8[] memory _probability, uint8[] memory _prize) {
        number=_prizeAddr.length;
        setPrizeAddr(_prizeAddr, _probability, _prize);
    }

    function setPrizeAddr(address[] memory _prizeAddr,uint8[] memory _probability, uint8[] memory _prize) public{
        require(number==_prize.length,"length of the probalibity and prizeAddr sould be equal to the number");
        require((_probability.length==_prize.length && _probability.length==_prizeAddr.length),"length of the probalibity and prizeAddr sould be equal");
        require(owner==msg.sender,"only owner");
        number=_prizeAddr.length;
        uint8 sum;
        for(uint8 i; i<number; i++){
            prizeAddr[i]=_prizeAddr[i];
            sum=sum+_probability[i];
            _probability[i]=_probability[i];
            prize[i]=_prize[i];
        }
        require(100==sum,"please ensure the sum is 100");
    }


    function play(bytes32 _commitment) public payable {
        require(msg.value == 1 ether, "Please pay 1 ETH to play the lottery.");   //??
        uint randomValue = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 100;
        uint8 Now; // 計算所有獎品機率的總和
        for(uint8 i; i < number; i++) {
            Now=Now+prize[i];
            if(randomValue<Now){
                Iprize(prizeAddr[i]).deposit(_commitment); //run the contract of the.......
                break;
            }
        }
    }

    function getPrizeInfo() view public returns(address[] memory,uint8[] memory,uint8[] memory){
        return (prizeAddr, probability, prize);
    }
}
