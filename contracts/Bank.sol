// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;


contract Bank{

event Deposit(address _ads,uint256 amount);//定义存了多少钱
event Drawdraw(uint256 amount);//输出取了多少钱
address public immutable  owner ;

 //存钱

 receive() external payable {

   emit Deposit(msg.sender, msg.value);

  }

 //只有合约onwer 可以取钱

  constructor() payable  {
    owner = msg.sender;
  }


 //只要取钱就销毁合约
 //取钱

  function drawMoeny() public {
    require(owner == msg.sender,"Not onwer");
    emit Drawdraw(owner.balance);
    selfdestruct(payable(msg.sender));//自毁函数
  }

 function getBalance() external view returns(uint256){
    return address(this).balance;
 }

}