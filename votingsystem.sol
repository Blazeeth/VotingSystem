// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract votingsystem {
    // Struct to hold voter details
    struct Voter {
        bool voted;
        uint8 voteIndex;
        uint256 weight;
    }

    // Struct to hold proposal details
    struct Proposal {
        string name;
        uint256 voteCount;
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    // Events for logging
    event ProposalAdded(uint256 proposalIndex, string proposalName);
    event Voted(address indexed voter, uint256 proposalIndex);
    event VotingEnded(uint256 winningProposalIndex, string winningProposalName);

    // Modifier to restrict access to chairperson
    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson can execute this.");
        _;
    }

    // Constructor to initialize the contract
    constructor(string[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
            emit ProposalAdded(i, proposalNames[i]);
        }
    }

    // Function to give voting rights to an address
    function giveRightToVote(address voter) public onlyChairperson {
        require(!voters[voter].voted, "The voter has already voted.");
        require(voters[voter].weight == 0, "The voter already has the right to vote.");
        voters[voter].weight = 1;
    }

    // Function to cast a vote
    function vote(uint8 proposalIndex) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote.");
        require(!sender.voted, "Already voted.");
        require(proposalIndex < proposals.length, "Invalid proposal index.");

        sender.voted = true;
        sender.voteIndex = proposalIndex;

        proposals[proposalIndex].voteCount += sender.weight;
        emit Voted(msg.sender, proposalIndex);
    }

    // Function to calculate the winning proposal
    function winningProposal() public view returns (uint256 winningProposalIndex) {
        uint256 winningVoteCount = 0;
        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalIndex = i;
            }
        }
    }

    // Function to end the voting and announce the winner
    function endVoting() public onlyChairperson {
        uint256 winningIndex = winningProposal();
        emit VotingEnded(winningIndex, proposals[winningIndex].name);
    }
}
