// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

contract TodoList {
    struct Todo {
        string content;
        bool complated;
    }

    Todo[] public list;

    //创建任务
    function create(string memory name) public {
        Todo memory todo = Todo(name, false);
        list.push(todo);
    }

    modifier checkList(uint index) {
        require(index < list.length, "Index out of range");
        _;
    }

    //删除任务
    function deleteTodo(uint256 index) public  checkList(index){
        // require(index < list.length, "Index out of range");

        for (uint i = index; i < list.length - 1; i++) {
            list[i] = list[i + 1];
        }
        list.pop();
    }

    //修改任务名称
    function updateContent(uint256 index, string memory name) public checkList(index) {
         // require(index < list.length, "Index out of range");
        list[index].content = name;
    }

    //设置完成标识
    function setComplated(uint index, bool complated) public {
        list[index].complated = complated;
    }
}
