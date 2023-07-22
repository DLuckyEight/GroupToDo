// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract ToDoAssignment {
	address public assigner;
	address[] public group;
	mapping(uint => bool) public existInGroup;
	
	enum TaskStatus{
		Incomplete,
		Completed
	}
	
	struct ToDo{
		address assignee;
		address assigner;
		string taskname;
		TaskStatus status;
	}
	
	ToDo[] todos;
		
	constructor(){
		assigner = msg.sender;
		group.push(msg.sender);
		existInGroup[uint(uint160(msg.sender))] = true;
	}
	
	modifier onlyAssigner(){
		require(msg.sender == assigner, "Only the assigner (contract deployer or group leader) can assign a task.");
		_;
	}

	modifier onlyGroup(){
		require(existInGroup[uint(uint160(msg.sender))] == true, "Only addresses that are part of the group can view ToDo list.");
		_;
	}

	// assign a new task to an assignee
	function assign(address _assignee, string memory _taskname) public onlyAssigner {
		if (existInGroup[uint(uint160(_assignee))] != true){
			group.push(_assignee);
			existInGroup[uint(uint160(_assignee))] = true;
		}
		ToDo memory item = ToDo(_assignee, assigner, _taskname, TaskStatus.Incomplete);   
		todos.push(item);
	}
	
	// reassign an existing task to a different assignee
	function reassign(uint _taskid, address _assignee) public onlyAssigner{
		require(todos[_taskid].status == TaskStatus.Incomplete, "Only an incomplete task can be reassigned.");
		require(todos[_taskid].assignee != _assignee, "The current and new assignee must be different when a task is reassigned.");
		
		if (existInGroup[uint(uint160(_assignee))] != true){
			group.push(_assignee);
			existInGroup[uint(uint160(_assignee))] = true;
		}
		todos[_taskid].assignee = _assignee;   
	}
	
	// complete a task
	function completeTask(uint _taskid) public {
		require(todos[_taskid].assignee == msg.sender, "You can only complete the task you have been assigned to.");
		
		todos[_taskid].status = TaskStatus.Completed;   
	}
  
	// show all people in this group (team leader and his team members) to public
	function showGroup() public view returns(address[] memory){
        	return group;
    	}
	
	// show total number of people in this group to public
	function countGroup() public view returns(uint){
        	return group.length;
    	}	
	
	// show all tasks to this group only
	function showToDo() public view onlyGroup returns(ToDo[] memory) {
        	return todos;
    	}		
}