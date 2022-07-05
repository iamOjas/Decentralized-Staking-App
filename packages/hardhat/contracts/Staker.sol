// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  uint256 public constant threshold = 1 ether; 
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw;
  bool public executeExecuted;

  event Stake(address staker,uint256 amount);

  mapping(address=> uint256) public balances;


  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )


  function stake() public payable executeExecuted_ {
    
    uint256 amount = msg.value;

    balances[msg.sender] += amount;

    emit Stake(msg.sender, amount);

  }


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  function execute() public executeExecuted_{
    require(block.timestamp >= deadline);

    if(address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
      executeExecuted = true;
    }

    else{
          openForWithdraw = true;
          executeExecuted = true;
    }

  }


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance
  function withdraw() public{
    require(openForWithdraw);

    uint256 amount = balances[msg.sender];
    
    balances[msg.sender] = 0;

    (bool _sent, ) = payable(msg.sender).call{value: amount}("");
    require(_sent,"Failed to send Ether");

  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  function timeLeft() public view returns(uint256){
      if(block.timestamp < deadline){
        return (deadline - block.timestamp);
      }
      else{
        return 0;
      }
  }

  // Add the `receive()` special function that receives eth and calls stake()

  receive() external payable{
    stake();
  }

  modifier executeExecuted_ (){
    require(!executeExecuted);
    _;
  }

}
