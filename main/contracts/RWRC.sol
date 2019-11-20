
// This is going to be the file for RWRC
//

contract RWRC(uint taskid, uint number_of_verifiers) {
	
	enum State { Unadopted, Waiting_for_verifier, Verified, Completed} 
	address owner;
	uint balance;
	uint verifiers;
	address[] verifiersList;
		
	constructor() public {	
		tid = taskid;
		owner = msg.sender;
		balance = msg.value;
		verifiers = number_of_verifiers;
	}
	
	// When a verfier verifies a task, he is added to a list, once the length of the list of addresses of verifiers
	// corresponds to the required number of verifiers explicitly asked by the requester
		
	function verify() public boolean{
		
		for (uint i = 0; verifierList.length; i++){
			if (list[i] == msg.sender){
				return False;
			}
		}
		
		list.push(msg.sender);
		
		return true;
	}

}

