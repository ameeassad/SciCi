pragma solidity ^0.5.11;

contract RWRC{

	enum State { Unadopted, Waiting_for_verifier, Verified, Completed}
	address owner;
	uint256 tid;
	// deadline 
	uint256 price;
	uint256 stake; 
	uint256 verifiers;
	address[] verifiersList;

	constructor(uint256 taskid, uint256 number_of_verifiers, uint256 pay, uint256 stake_amount) public {
		tid = taskid;
		owner = msg.sender;
		price = pay;
		stake = stake_amount; 
		verifiers = number_of_verifiers;
	}

	// When a verfier verifies a task, he is added to a list, once the length of the list of addresses of verifiers
	// corresponds to the required number of verifiers explicitly asked by the requester

	function add_verifier() public returns(bool){

		for (uint i = 0; i < verifiersList.length; i++){
			if (verifiersList[i] == msg.sender){
				return false;
			}
		}

		verifiersList.push(msg.sender);
		return true;
	}

	// transfer 
	// validate task 
	// adopted by a worker 

}

