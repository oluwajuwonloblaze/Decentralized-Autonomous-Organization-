pragma solidity ^0.8.13;

contract DAO {
    struct Proposal {
        string description;
        uint votecount;
        bool executed;
    }

    struct Member {
        address memberAddress;
        uint membersince;
        uint tokenbalance;
    }

    address[] public members;
    mapping(address => Member) public memberinfo;
    mapping(address => mapping(uint => bool)) public votes;
    Proposal[] public proposals;
    uint public totalsupply;
    mapping(address => uint) public balances;

    event ProposalCreated(uint indexed proposalId, string description);
    event VoteCast(address indexed voter, uint proposalId, uint tokenAmount);

    function addMember(address _member) public {
        require(memberinfo[_member].memberAddress == address(0), "already exists");

        memberinfo[_member] = Member({
            memberAddress: _member,
            membersince: block.timestamp,
            tokenbalance: 100
        });

        members.push(_member);
        balances[_member] = 100;
        totalsupply += 100;
    }

    function removeMember(address _member) public {
        require(memberinfo[_member].memberAddress != address(0), "does not exist");

        memberinfo[_member] = Member({
            memberAddress: address(0),
            membersince: 0,
            tokenbalance: 0
        });

        for (uint i = 0; i < members.length; i++) {
            if (members[i] == _member) {
                members[i] = members[members.length - 1];
                members.pop();
                break;
            }
        }

        balances[_member] = 0;
        totalsupply -= 100;
    }

    function createProposal(string memory _description) public {
        proposals.push(
            Proposal({
                description: _description,
                votecount: 0,
                executed: false
            })
        );

        emit ProposalCreated(proposals.length - 1, _description);
    }

    function vote(uint _proposalId, uint _tokenAmount) public {
        require(memberinfo[msg.sender].memberAddress != address(0), "only members can vote");
        require(balances[msg.sender] >= _tokenAmount, "not enough tokens");
        require(!votes[msg.sender][_proposalId], "You already voted");

        votes[msg.sender][_proposalId] = true;
        memberinfo[msg.sender].tokenbalance -= _tokenAmount;
        proposals[_proposalId].votecount += _tokenAmount;

        emit VoteCast(msg.sender, _proposalId, _tokenAmount);
    }

    function executeProposal(uint _proposalId) public {
        require(proposals[_proposalId].executed == false, "already executed");
        require(proposals[_proposalId].votecount > totalsupply / 2, "not enough votes");

        proposals[_proposalId].executed = true;
    }
}
