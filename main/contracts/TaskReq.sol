pragma solidity ^0.5.11;
import "./registration.sol";

contract TaskReq{
    address payable public owner;

	enum State {Unfunded, Unadopted, Adopted, Waiting_for_verifier, Verified, Not_Verified, Completed}
	State public default_state = State.Unfunded;

	uint256 public tid = 0;
	uint256 public vrf_num = 0; 
	uint256 public req_stake;  // requester stake
	uint256 public wrk_stake;  // tasker stake 
	uint256 public vrf_stake;  // pool of verifier stake
	uint256 public vrf_ans = 0; // the number of verifier answered
	uint256 public set_pay;
	address payable public tasker;
	string public description;
	bytes32 public answer_hash;
	uint public deadline; 
    Registration reg;
	Verifier[3] public verifiers;


    //Removed public keyword in variabls below
	struct Verifier{
		bool done;
		bool approved;
		address payable public_addr; 
	}

	//event Transfer(address _from, address _totasker, address _toverifier);
	//event Task_completed(address wrker, bytes32 answer);

	constructor(string memory des, address regis_addr, uint pay, uint duration) public {
	    reg = Registration(regis_addr);
	    
	    require(reg.isRequester(msg.sender), "You are not registered to be a requester");
	    tid = reg.addTaskCount();
		owner = msg.sender;
		description = des;
		set_pay = pay;
		deadline = now + duration;
		reg.addReq(owner);
	}

	// donors donate 
	function donate() public payable{
		req_stake += msg.value;
		
		if (req_stake >= set_pay){
			default_state = State.Unadopted;
		}

	}

	// tasker adopt a task
	// TODO: interfacing with registration contract 
	function tasker_adopt() public payable returns(bool){
	    //check if taskers
	    require(reg.isTasker(msg.sender), "You are not registered to be a tasker");
	    require(owner != address(0x0), "error: This task is adopted by another tasker");
		require(owner != msg.sender, "error: requester as tasker");
		require(default_state == State.Unadopted, "error: the task is not yet ready for adoption");
		require(msg.value > 0, "error: stake has to be larger than zero");

		// setup tasker to task
		tasker = msg.sender;
		wrk_stake += msg.value;
		default_state = State.Adopted;
		return true;

	}

	// tasker complete task 
	function complete_task(string memory ans) public returns(bool) {
		require(owner != msg.sender, "error: requester as tasker");
		require(tasker == msg.sender, "error: wrong tasker completion");
		require(default_state == State.Adopted, "error: State error");

		// tasker has completed task
		default_state = State.Waiting_for_verifier;
		answer_hash = keccak256(bytes(ans));

		return true;
	}

	function verifier_adopt() public payable returns(bool) {
	    require(default_state == State.Waiting_for_verifier, "error: State error");
	    require(vrf_num < 3, "error: State error");
	    require(reg.isVerifier(msg.sender), "You are not registered to be a verifier");
		require(tasker != msg.sender, "error: tasker as verifier");
		require(msg.value > 0, "error: Verifier stake cannot be zero");
		
	    bool dup_verifier = false; 
	    
	    for (uint i = 0; i < vrf_num; i++){
	        if (verifiers[i].public_addr == msg.sender) { 
	            dup_verifier = true;
	            break;
	        }
	    }

	    require(!dup_verifier, "error: dupicate verifier");
		
		//setup verifier
		Verifier memory v = Verifier(false, false, msg.sender); 
	    verifiers[vrf_num] = v;
		vrf_num ++;
		vrf_stake += msg.value;
	}

	// Verifier does not approve the answer_hash
	function verify_task(bool approve_choice) public returns(bool) {
	    require(vrf_num > 0, "errer: no verifier");
		require(msg.sender != tasker, "error: tasker as verifier");
		
        bool verifier_exist = false; 
	    
	    for (uint i = 0; i < vrf_num; i++){
	        if (verifiers[i].public_addr == msg.sender) { 
	            verifier_exist = true;
	            break;
	        }
	    }
	    
	    require(verifier_exist, "error: verifier does not exist");

		// change this mapping
		reg.addVeri(msg.sender);
		verifiers[vrf_ans].done = true; 
		verifiers[vrf_ans].approved = approve_choice; 
		vrf_ans ++; 

		// Check if all verifier has answered, find consensus
		if (vrf_ans == 3){

			bool consensus = find_consensus();
			address payable temp_addr = address(0x0);

			for(uint i = 0; i < vrf_num; i++){
				if (verifiers[i].approved != consensus){
					temp_addr = verifiers[i].public_addr;
				}
			}

			if (consensus == false){
			    reg.taskFailed(tasker);
				if (temp_addr != address(0x0)){
					dis_min(temp_addr);
				} else {
					dis_all();
				} 

				handle_tasker_failure(); // reset the contract 
			} else {
			    reg.taskCompleted(tasker);
				if (temp_addr != address(0x0)){
					app_min(temp_addr); // stack pool goes to the majority
				} else {
					app_all();
				}

			}
		}

		return true;
	}

	function find_consensus() public view returns(bool){

		uint approved = 0; 
		uint disapproved = 0;
		bool result; 

		for(uint i = 0; i < vrf_num; i++){
			if (verifiers[i].approved == true){
				approved++;
			}else{
				disapproved++;
			}
		}

		if (approved > disapproved){
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

		reg.decreaseReputation(tasker, 20, true);
		tasker = address(0x0);
	}

	function transfer_checked(address payable _to, uint256 _amount) public payable {
		if (address(this).balance < _amount ) revert();
        _to.transfer(_amount);
    }

	// approved, all app
	// calculation for all the transfers 
	function app_all() private {
		// stake refund back
		transfer_checked(tasker, req_stake*7/10);
		uint256 vrf_pay = req_stake/10 + vrf_stake/3;
		for(uint i = 0; i < vrf_num; i++){
			transfer_checked(verifiers[i].public_addr, vrf_pay);
			reg.increaseReputation(verifiers[i].public_addr, 20, false);	
		}
		
		transfer_checked(tasker, address(this).balance);
	}

	function app_min(address min) private {
        uint256 temp = vrf_stake/2;
        uint256 comb_stake = (req_stake/10) + temp;
        
        for (uint i = 0; i < vrf_num; i++){
            
            if ((verifiers[i]).public_addr != min){
                transfer_checked((verifiers[i]).public_addr, comb_stake);
				reg.increaseReputation(verifiers[i].public_addr, 20, false);
            } else {
				reg.decreaseReputation(verifiers[i].public_addr, 20, true);		
			}
			
        }
		transfer_checked(tasker, address(this).balance);
    }

	function dis_min(address min) private {
		// workers stake + vrf_stake 
		uint256 temp = wrk_stake + vrf_stake;
		for(uint256 i = 0; i < vrf_num; i++){
			if (verifiers[i].public_addr != min){
				transfer_checked(verifiers[i].public_addr, temp/2);
				reg.increaseReputation(verifiers[i].public_addr, 20, false);
			}else{
				reg.decreaseReputation(verifiers[i].public_addr, 20, true);	
			}
		}
	}

	function dis_all() private {
	    uint256 comb_stake = (wrk_stake+vrf_stake)/3;
		for(uint256 i = 0; i < vrf_num; i++){
			transfer_checked(verifiers[i].public_addr, comb_stake);
			reg.increaseReputation(verifiers[i].public_addr, 20, false);
		}
    }

	function cancelTask() public payable{
	   
	    if ( now > deadline ){
	       owner.transfer(req_stake);
		   selfdestruct(owner);
	    }
	}
	
	function getContractBalance() public view returns(uint){
	    return address(this).balance;
	}

}