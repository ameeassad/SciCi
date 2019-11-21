pragma solidity ^0.5.11;

contract RWRC{

	enum State {Unadopted, Adopted, Waiting_for_verifier, Verified, Not_Verified, Completed};
	State default_state = State.Unadopted;
    enum Level {High, Low};
	Level level = Level.Low; 

	address payable owner;
	uint256 tid;
	// TODO deadline variable 
	uint256 vrf_num = 0; 
	uint256 req_stake;  // requester stake
	uint256 wrk_stake;  // worker stake 
	uint256 vrf_stake;  // pool of verifier stake
	uint256 vrf_ans = 0; // the number of verifier answered
	address payable worker;
	string description;
	string answer;

	Verifier[] verifiers; 
	struct Verifier{
		public bool done;
		public bool approved;
		public address payable public_addr; 
	}

	address usc_addr;
    uint amount;

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

		USC uc = USC(usc_addr)
		uc.updatetaskcount();
		depositFunds(); 
	}

	// FALL BACK FUNCTION TODO
	function () public payable{
        depositFunds();
    }

    function depositFunds() payable{
        amount += msg.value;
    }

	// worker adopt a task
	// TODO: interfacing with registration contract 
	function worker_adopt(uint256 stake) public returns(bool){
		require(owner != msg.sender, "error: requester as worker");

		// setup worker to task
		worker = msg.sender;
		wrk_stake = stake; 
		default_state = State.Adopted;
		return true;
	}

	// Worker complete task 
	function complete_task(string memory ans) public returns(bool){
		require(owner != msg.sender, "error: requester as worker");

		// worker has completed task
		default_state = State.Waiting_for_verifier;
		answer = ans;
		return true;
	}

	function verifier_adopt(uint256 stake) public returns(bool){
		require(worker != msg.sender, "error: worker as verifier");
		
		//setup verifier
		if (vrf_num <= 3){
			verifiers[vrf_num-1] = new Verifier(false, false, msg.sender);
			vrf_num++;
			vrf_stake += stake;
		}
	}

	// Verifier does not approve the answer
	function verify_task(bool approve_choice) public returns(bool){
		require(msg.sender != worker, "error: worker as requester");

		// TODO: check reputation in registration contract 
		vrf_ans ++; 
		verifiers[vrf_ans].done = true; 
		verifiers[vrf_ans].approved = approve_choice; 

		// Check if all verifier has answered, find concensus
		if (vrf_ans == 3){

			bool concensus = find_consensus()
			address temp_addr = address(0x0);
			for(int i = 0; i < vrf_num; i++){
				if (verifiers[i].approved != concensus){
					temp_addr = verifiers[i].public_addr;
				}
			}

			if (concensus == false){
				// worker is disapproved

		        // penalized consensus minority	
				if (temp_addr != address(0x0)){
					// transfer worker stack to majority
				}

				handle_worker_failure();
				
				// worker stake to requester stake
			} else {
				// worker is approved


				// penalized consensus minority
				if (temp_addr != address(0x0)){
					// stack pool goes to the majority 
				}

			}
		}

		return true;
	}

	function find_concensus() public returns(bool){

		uint approved = 0; 
		uint disapproved = 0;
		bool result; 

		for(int i = 0; i < vrf_num; i++){
			if (verifers[i].approved == true){
				approved++;
			}else{
				disapproved++;
			}
		}

		if (approved > dispproved){
			result = true;
		} else {
			result = false; 
		}

		return result; 
	}


	// helper 
	function handle_worker_failure() public returns(bool){
		require(default_state == State.Not_Verified, "error: handle_worker_failure");
		// transfer wrk stakes to requester
	}


	event Transfer(address _from, address _toworker, address _toverifier)
    
	// requester to worker/verifier 
	function transferApproved(){
		
		worker.transfer(wrk_stake)
		worker.transfer((8*amount)/10);
		verifier.transfer((2*amount)/10); 
		
		emit transfer(address(this) , worker, verifier)
		// TODO change percentage depending on no verifiers
        
	}
	
	// requester 
	function transferRejected(){
	   verifier.transfer(wrk_stake)
	   //TODO add multiple verifiers
	}

}

