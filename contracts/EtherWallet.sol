// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//1.学习三种取钱方法(转出)
//2.学习接收转账的方法
contract EtherWallet {
    address payable public immutable owner;
    event Log(address addr, uint amount);
    event Save(address addr, uint amount);

   

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {
      emit Save(msg.sender,msg.value);
    }

    function withdraw(uint _amount) external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(msg.sender).transfer(_amount);
        emit Log(msg.sender, _amount);
    }

    function withdraw2(uint _amount) external {
        require(msg.sender == owner, "Not owner");
        bool success = payable(msg.sender).send(_amount);
        require(success, "Send Failed");
        emit Log(msg.sender, _amount);
    }

    function withdraw3(uint _amount) external {
        require(msg.sender == owner, "Not owner");

        (bool success, bytes memory data) = payable(msg.sender).call{
            value: _amount
        }(""); //转账200wai
        require(success, "Send Failed");
        emit Log(msg.sender, _amount);

    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}
