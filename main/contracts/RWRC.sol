pragma solidity ^0.5.11;

contract RWRC{

	enum State {Unadopted, Adopted, Waiting_for_verifier, Verified, Not_Verified, Completed};
	State default_state = State.Unadopted;
    enum Level {High, Low};

	// Get rid of difficulty level
	Level level = Level.Low; 

	address payable owner;
	uint256 tid;
	// TODO deadline variable 
	uint256 vrf_num = 0; 
	uint256 req_stake;  // requester stake
	uint256 wrk_stake;  // tasker stake 
	uint256 vrf_stake;  // pool of verifier stake
	uint256 vrf_ans = 0; // the number of verifier answered
	address payable tasker;
	string description;
	string answer;

	Verifier[] verifiers; 
	struct Verifier{
		public bool done;
		public bool approved;
		public address payable public_addr; 
	}

	Registration reg; 

	event Transfer(address _from, address _totasker, address _toverifier)

	constructor(uint256 taskid, uint256 dif_level, string memory des, address regis_addr) public {
		tid = taskid;
		owner = msg.sender;
		description = des;

		if (dif_level == 1){
			level = Level.High;
		} else {
			level = Level.Low; 
		}

		reg = Registration(regis_addr)
		reg.addTaskCount():
		depositFunds(); 
	}

	// FALL BACK FUNCTION TODO
	function () public payable{
        depositFunds();
    }

    function depositFunds() payable{
        req_stake += msg.value;
    }

	// tasker adopt a task
	// TODO: interfacing with registration contract 
	function tasker_adopt(uint256 stake) public payable returns(bool){
		require(owner != msg.sender, "error: requester as tasker");

		// setup tasker to task
		tasker = msg.sender;
		//TODO transfer stake from worker
		wrk_stake += msg.value;
		default_state = State.Adopted;
		return true;
	}

	// tasker complete task 
	function complete_task(string memory ans) public returns(bool) {
		require(owner != msg.sender, "error: requester as tasker");

		// tasker has completed task
		default_state = State.Waiting_for_verifier;
		answer = sha3(ans);
		// emit answer ? 
		return true;
	}

	function verifier_adopt(uint256 stake) public returns(bool) { 
		require(tasker != msg.sender, "error: tasker as verifier");
		
		//setup verifier
		if (vrf_num <= 3){
			verifiers[vrf_num-1] = new Verifier(false, false, msg.sender);
			vrf_num++;
			vrf_stake += msg.value;
		}
	}

	// Verifier does not approve the answer
	function verify_task(bool approve_choice) public returns(bool){
		require(msg.sender != tasker, "error: tasker as requester");

		// TODO: check reputation in registration contract 
		vrf_ans ++; 

		// change this mapping 
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
				// tasker is disapproved

				if (temp_addr != address(0x0)){
					dis_min(temp_addr);
				} else {
					dis_all();
				} 

				handle_tasker_failure(); // reset the cnotract 
				
				// tasker stake to requester stake
			} else {
				// tasker is approved

				if (temp_addr != address(0x0)){
					app_min(temp_addr); // stack pool goes to the majority
				} else {
					app_all();
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
	function handle_tasker_failure() public returns(bool){
		require(default_state == State.Not_Verified, "error: handle_tasker_failure");

		// reset all variables
		default_state = State.Unadopted; 
		wrk_stake = 0;
		vrf_stake = 0;
		vrf_num = 0;
		vrf_ans = 0; 

		// empty the array 

	}

	function transfer_checked(address _to, uint256 _amount) public payable {
		if (address(this).balance > _amount ) throw;
        _to.transfer(_amount);
    }

	// approved, all app
	// calculation for all the transfers 
	function app_all() private payable{
		// stake refund back
		transfer_checked(tasker, req_stake*7/10);
		uint256 vrf_pay = req_stake/10 + vrf_stake/3;
		for(int i = 0; i < vrf_num; i++){
			transfer_checked(verifiers[i].public_addr, vrf_pay);
		}
	}

	function app_min(address min) private payable{
        uint256 temp = vrf_stake/2;
        uint256 comb_stake = (req_stake/10) + temp;
        for (uint i = 0; i < vrf_num; i++){
            if ((verifiers[i]).public_addr != min){
                transfer_checked((verifiers[i]).public_addr, comb_stake);    
            }
        }

		transfer_checked(tasker, req_stake*8/10);
    }

	function dis_min(address min) private payable{
		// workers stake + vrf_stake 
		uint256 temp = wrk_stake + vrf_stake;
		for(uint256 i = 0; i < vrf_num; i++){
			if (verifiers[i].public_addr != min){
				transfer_checked(verifiers[i].public_addr, temp/2);
			}
		}
	}

	function dis_all() private {
	    uint256 comb_stake = (wrk_stake+vrf_stake)/3;
		for(uint256 i = 0; i < vrf_num; i++){
			transfer_checked(verifiers[i].public_addr, comb_stake);
		}
    }


}

