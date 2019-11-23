pragma solidity ^0.5.11;


contract Registration{
    
    address owner;
    address payable wallet;
    uint256 public actorCount = 0;
    uint256 public donorCount = 0;
    uint256 public taskerCount = 0;
    uint256 public requesterCount = 0;
    uint256 public verifierCount = 0;
    uint256 public taskCount = 0;
    uint256 public transactionCount = 0;
    uint256 public constant threshold = 120;
    // list of tasks

    mapping(address => Actor) public actors;
    mapping(address => Tasker) public taskers;
    mapping(address => Requester) public requesters;
    mapping(address => Verifier) public verifiers;

    struct Actor {
        address payable public_addr;
        bool requester;
        bool tasker;
        bool verifier;
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
        require(taskers[msg.sender].public_addr == address(0x0), "Duplicate registration");

        if (actors[msg.sender].public_addr == address(0x0)){
            actors[msg.sender] = Actor(msg.sender, false, true, false, 100);
            actorCount += 1;

            taskers[msg.sender] = Tasker(msg.sender, 0, 0);
            taskerCount += 1;
        }else{
            if (taskers[msg.sender].public_addr == address(0x0)){
                taskers[msg.sender] = Tasker(msg.sender, 0, 0);
                taskerCount += 1;
            }
            actors[msg.sender].tasker = true;
        }

    }

    function registerReq() public {
        require(requesters[msg.sender].public_addr == address(0x0), "Duplicate registration");

        if (actors[msg.sender].public_addr == address(0x0)){
            actors[msg.sender] = Actor(msg.sender, true, false, false, 100);
            actorCount += 1;

            requesters[msg.sender] = Requester(msg.sender, 0);
            requesterCount += 1;
        }else{
            if (requesters[msg.sender].public_addr == address(0x0)){
                requesters[msg.sender] = Requester(msg.sender, 0);
                requesterCount += 1;
            }
            actors[msg.sender].requester = true;
        }
    }

    function registerVerifier(address addr) public {
        require(verifiers[addr].public_addr == address(0x0), "Duplicate registration");

        verifiers[addr] = Verifier(address(uint160(addr)), 0);
        actors[addr].verifier = true;
        verifierCount += 1;
    }

    function removeVerifier(address addr) public {
        require(verifiers[addr].public_addr != address(0x0), "Duplicate remove registration");
        actors[addr].verifier = false;
        verifierCount--; 
        delete verifiers[addr];
    }

    function getRep(address addr) public view returns (uint256){
        require(actors[addr].public_addr != address(0x0), "Address does not exist");
        return actors[addr].reputation;
    }

    function addTaskCount() public returns(uint256){
        taskCount += 1;
        return taskCount;
    }

    //increase reputation by inc if task is approved
    //value of inc depends on the level of the task
    function increaseReputation(address addr, uint inc, bool isWorker) public returns(uint256){
        actors[addr].reputation += inc;

        //kind equals 0 if addr belongs to tasker/worker
        if ( actors[addr].verifier == false && isWorker && actors[addr].reputation > threshold){
            registerVerifier(addr);
        }
        
        return actors[addr].reputation;
    }

    //decrease reputation by inc if task is rejected
    //value of dec depends on the level of the task
    function decreaseReputation(address addr, uint dec, bool isVerifier) public returns(uint256){
        actors[addr].reputation -= dec;

        if ( isVerifier && actors[addr].reputation < threshold){
            removeVerifier(addr);
        }
        
        return actors[addr].reputation;
    }

    //track number of tasks worker has completed
    function taskCompleted(address addr) public {
        Tasker storage tasker = taskers[addr];
        tasker.num_job_done += 1;
    }

    function taskFailed(address addr) public {
        Tasker storage tasker = taskers[addr];
        tasker.num_job_fail += 1;
    }
    
    function addReq(address addr) public {
        Requester storage req = requesters[addr];
        req.num_req += 1;
    }
    
    function addVeri(address addr) public {
        Verifier storage veri = verifiers[addr];
        veri.num_veri += 1;
    }
    
    function isTasker(address addr) public view returns(bool) {
        return actors[addr].tasker;
    }
    
    function isRequester(address addr) public view returns(bool) {
        return actors[addr].requester;
    }
    
    function isVerifier(address addr) public view returns(bool) {
        return actors[addr].verifier;
    }
    
}