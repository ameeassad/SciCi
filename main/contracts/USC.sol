pragma solidity ^0.5.11;


contract registration{
    
    address owner;
    address payable wallet;

    uint256 public buyerCount = 0;
    uint256 public taskerCount = 0;
    uint256 public requestorCount = 0;
    uint256 public verifierCount = 0;
    uint256 public taskCount = 0;
    uint256 public transactionCount = 0;

    mapping(address => Actor) public actors; 
    mapping(address => Tasker) public taskers;
    mapping(address => Requester) public requesters;
    mapping(address => Verifier) public verifiers;

    struct Actor {
        address payable public_arr;
        bool reqer;
        bool tasker;
        bool verifer;
        uint reputation;
    }

    struct Tasker {
        address payable public_addr; 
        uint num_job_done;
        uint num_job_fail;
    }

    struct Requester {
        address payable public_addr;
        uint num_req;
    }

    struct Verifier {
        address payable public_addr;
        uint num_veri;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
        wallet = msg.sender; 
    }

    function registerTasker() public {
        
        if (taskers[msg.sender].isValue){
            taskers[msg.sender] = Tasker(msg.sender, 0, 0);
            taskerCount += 1;

            actors[msg.sender] = Tasker(msg.sender, true, false, false, 100);
        }
    }

    function registerReq() public {
        if (requesters[msg.sender].isValue){
            requesters[msg.sender] = Requester(msg.sender, 0);
            buyerCount += 1;

            actors[msg.sender] = Tasker(msg.sender, false, true, false, 100);
        }
    }

    function registerVerifier() public {
        if (verifiers[msg.sender].isValue){
            verifiers[msg.sender] = Verifier(msg.sender, 0);
            buyerCount += 1;

            actors[msg.sender] = Tasker(msg.sender, false, false, true, 100);
        }
    }

    function getRep(uint rep) public view returns (int){
        return;
    }


}