pragma solidity ^0.5.11;

contract RWRC{

	enum State {Unadopted, Adopted, Waiting_for_verifier, Verified, Not_Verified, Completed};
	State default_state = State.Unadopted;
    enum Level {High, Low};
	Level level = Level.Low; 
	address owner;
	uint256 tid;
	// deadline
	uint256 stake;
	address verifier;
	address worker;
	string description;
	string answer;


	constructor(uint256 taskid, uint256 dif_level, uint256 stake_amount, string memory des) public {
		tid = taskid;
		owner = msg.sender;
		stake = stake_amount;
		description = des;

		if (dif_level == 1){
			level = Level.High;
		} else {
			level = Level.Low; 
		}
	}

	// worker adopt a task
	// TODO: interfacing with registration contract
	function worker_adopt() public returns(bool){
		require(owner != msg.sender, "error: requester as worker");

		// add worker address
		worker = msg.sender;
		default_state = State.Adopted;
		return true;
	}

	function complete_task(string memory ans) public returns(bool){
		require(owner != msg.sender, "error: requester as worker");

		// worker has completed task
		default_state = State.Waiting_for_verifier;
		answer = ans;
		return true;
	}

	function verify_task(bool approve_choice) public returns(bool){
		require(msg.sender != worker, "error: worker as requester");

		// add verifier
		verifier = msg.sender;

		if (approve_choice){
			default_state = State.Verified;
		} else {
			default_state = State.Not_Verified;
			handle_worker_failure();
		}

		return true;
	}

	function handle_worker_failure() public returns(bool){
		require(default_state == State.Not_Verified, "error: handle_worker_failure");

	}

	// transfer 
	// validate task 
	// adopted by a worker 

}

