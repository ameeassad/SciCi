
// This is going to be the file for RWRC
//

contract RWRC(address owner_address, uint taskid, uint number_of_verifiers) {
	
	uint status = 0 // 0  = Unfinished, 1 = Finished
	address owner;
	uint balance;
	uint verifiers;
	uint[] list;
		
	constructor() public {	
		tid = taskid
		owner = owner_address;
		balance = msg.value;
		verifiers = number_of_verifiers;
	}
	
	// When a verfier verifies a task, he is added to a list, once the length of the list of addresses of verifiers
	// corresponds to the required number of verifiers explicitly asked by the requester
		
	function verify() public boolean{
		
		uint sender = msg.sender
		
		for ( uint i =0; list.length; i++ )
			if list[i] == sender;
				return False;
		
		list.push(msg.sender)
		
		return True;
	}

}

