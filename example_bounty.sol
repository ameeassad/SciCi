pragma solidity ^0.5.0;
/**
* https://kauri.io/article/124b7db1d0cf4f47b414f8b13c9d66e2/remix-ide-your-first-smart-contract 
* @title Bounties
* @author Joshua Cassidy- <joshua.cassidy@consensys.net>
* @dev Simple smart contract which allows any user to issue a bounty in ETH linked to requirements
* which anyone can fulfil by submitting the evidence of their fulfilment
*/
contract Bounties {
/*
* Enums
*/
enum BountyStatus { CREATED, ACCEPTED, CANCELLED }
/*
* Storage
*/
Bounty[] public bounties;
/*
* Structs
*/
struct Bounty {
    address issuer;
    uint deadline;
    string data;
    BountyStatus status;
    uint amount; //in wei
}
/**
* @dev Contructor
*/
constructor() public {}
/**
* @dev issueBounty(): instantiates a new bounty
* @param _deadline the unix timestamp after which fulfillments will no longer be accepted
* @param _data the requirements of the bounty
*/
function issueBounty(
    string memory _data,
    uint64 _deadline
)
public
payable
hasValue()
validateDeadline(_deadline)
returns (uint)
{
    bounties.push(Bounty(msg.sender, _deadline, _data, BountyStatus.CREATED, msg.value));
    emit BountyIssued(bounties.length - 1,msg.sender, msg.value, _data);
    return (bounties.length - 1);
}
/**
* Modifiers
*/
modifier hasValue() {
    require(msg.value > 0);
    _;
}
modifier validateDeadline(uint _newDeadline) {
    require(_newDeadline > now);
    _;
}
/**
* Events
*/
event BountyIssued(uint bounty_id, address issuer, uint amount, string data);
}
