pragma solidity ^0.5.11;


contract registration{
    
    address owner;
    address payable wallet;

    uint256 public actorCount = 0;
    uint256 public taskerCount = 0;
    uint256 public requesterCount = 0;
    uint256 public verifierCount = 0;
    uint256 public taskCount = 0;
    uint256 public transactionCount = 0;
    // list of tasks


    mapping(address => Actor) public actors;
    mapping(address => Tasker) public taskers;
    mapping(address => Requester) public requesters;
    mapping(address => Verifier) public verifiers;

    struct Actor {
        address payable public_addr;
        bool requestor;
        bool tasker;
        bool verifer;
        uint reputation;
    }

    struct Tasker {
        address payable public_addr;
        // list of addresses of task
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
        require(msg.sender == owner, "owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
        wallet = msg.sender;
    }

    function registerTasker() public {
        require(actors[msg.sender].public_addr == address(0x0), "Duplicate actors registration");
        require(taskers[msg.sender].public_addr == address(0x0), "Duplicate registration");

        taskers[msg.sender] = Tasker(msg.sender, 0, 0);
        taskerCount += 1;
        actors[msg.sender] = Actor(msg.sender, true, false, false, 100);
        actorCount += 1;
    }

    function registerReq() public {
        require(actors[msg.sender].public_addr == address(0x0), "Duplicate actors registration");
        require(requesters[msg.sender].public_addr == address(0x0), "Duplicate registration");

        requesters[msg.sender] = Requester(msg.sender, 0);
        requesterCount += 1;
        actors[msg.sender] = Actor(msg.sender, false, true, false, 100);
        actorCount += 1;
    }

    function registerVerifier() public {
        require(actors[msg.sender].public_addr == address(0x0), "Duplicate actors registration");
        require(verifiers[msg.sender].public_addr == address(0x0), "Duplicate registration");

        verifiers[msg.sender] = Verifier(msg.sender, 0);
        verifierCount += 1;
        actors[msg.sender] = Actor(msg.sender, false, false, true, 100);
        actorCount += 1;
    }

    function getRep(address addr) public view returns (uint256){
        require(actors[addr].public_addr != address(0x0), "Address does not exist");
        return actors[addr].reputation;
    }

    function getActorCount() public view returns(uint256){
        return actorCount;
    }

    function getTaskerCount() public view returns(uint256){
        return taskerCount;
    }

    function getRequesterCount() public view returns(uint256){
        return requesterCount;
    }

    function getVerifierCount() public view returns(uint256){
        return verifierCount;
    }

    function getTransactionCount() public view returns(uint256){
        return transactionCount;
    }




}