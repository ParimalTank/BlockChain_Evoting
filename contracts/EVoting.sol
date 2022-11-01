// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Types.sol";

contract EVoting {
    Types.Candidate[] public candidates;
    mapping(uint256 => Types.Voter) voter;
    mapping(uint256 => Types.Candidate) public candidate;
    mapping(uint256 => uint256) internal votesCount;

    address public electionChief;
    uint256 public votingStartTime;
    uint256 public votingEndTime;

    constructor(uint256 startTime_, uint256 endTime_) {
        initializeCandidateDatabase_();
        initializeVoterDatabase_();
        votingStartTime = startTime_;
        votingEndTime = endTime_;
        electionChief = msg.sender;
    }

    function getCandidateList(uint256 voterAadharNumber)
        public
        view
        returns (Types.Candidate[] memory)
    {
        Types.Voter storage voter_ = voter[voterAadharNumber];
        uint256 _politicianOfMyConstituencyLength = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (
                voter_.stateCode == candidates[i].stateCode &&
                voter_.constituencyCode == candidates[i].constituencyCode
            ) _politicianOfMyConstituencyLength++;
        }
        Types.Candidate[] memory cc = new Types.Candidate[](
            _politicianOfMyConstituencyLength
        );

        uint256 _indx = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (
                voter_.stateCode == candidates[i].stateCode &&
                voter_.constituencyCode == candidates[i].constituencyCode
            ) {
                cc[_indx] = candidates[i];
                _indx++;
            }
        }
        return cc;
    }

    function isVoterEligible(uint256 voterAadharNumber)
        public
        view
        returns (bool voterEligible_)
    {
        Types.Voter storage voter_ = voter[voterAadharNumber];
        if (voter_.age >= 18 && voter_.isAlive) voterEligible_ = true;
    }

    function didCurrentVoterVoted(uint256 voterAadharNumber)
        public
        view
        returns (bool userVoted_, Types.Candidate memory candidate_)
    {
        userVoted_ = (voter[voterAadharNumber].votedTo != 0);
        if (userVoted_)
            candidate_ = candidate[voter[voterAadharNumber].votedTo];
    }

    function vote(
        uint256 nominationNumber,
        uint256 voterAadharNumber,
        uint256 currentTime_
    )
        public
        votingLinesAreOpen(currentTime_)
        isEligibleVote(voterAadharNumber, nominationNumber)
    {
        voter[voterAadharNumber].votedTo = nominationNumber;

        uint256 voteCount_ = votesCount[nominationNumber];
        votesCount[nominationNumber] = voteCount_ + 1;
    }

    function getVotingEndTime() public view returns (uint256 endTime_) {
        endTime_ = votingEndTime;
    }

    function updateVotingStartTime(uint256 startTime_, uint256 currentTime_)
        public
        isElectionChief
    {
        require(votingStartTime > currentTime_);
        votingStartTime = startTime_;
    }

    function extendVotingTime(uint256 endTime_, uint256 currentTime_)
        public
        isElectionChief
    {
        require(votingStartTime < currentTime_);
        require(votingEndTime > currentTime_);
        votingEndTime = endTime_;
    }

    function getResults(uint256 currentTime_)
        public
        view
        returns (Types.Results[] memory)
    {
        require(votingEndTime < currentTime_);
        Types.Results[] memory resultsList_ = new Types.Results[](
            candidates.length
        );
        for (uint256 i = 0; i < candidates.length; i++) {
            resultsList_[i] = Types.Results({
                name: candidates[i].name,
                partyName: candidates[i].partyName,
                nominationNumber: candidates[i].nominationNumber,
                stateCode: candidates[i].stateCode,
                constituencyCode: candidates[i].constituencyCode,
                voteCount: votesCount[candidates[i].nominationNumber]
            });
        }
        return resultsList_;
    }

    modifier votingLinesAreOpen(uint256 currentTime_) {
        require(currentTime_ >= votingStartTime);
        require(currentTime_ <= votingEndTime);
        _;
    }

    modifier isEligibleVote(uint256 voterAadhar_, uint256 nominationNumber_) {
        Types.Voter memory voter_ = voter[voterAadhar_];
        Types.Candidate memory politician_ = candidate[nominationNumber_];
        require(voter_.age >= 18);
        require(voter_.isAlive);
        require(voter_.votedTo == 0);
        require(
            (politician_.stateCode == voter_.stateCode &&
                politician_.constituencyCode == voter_.constituencyCode)
        );
        _;
    }

    modifier isElectionChief() {
        require(msg.sender == electionChief);
        _;
    }

    function initializeCandidateDatabase_() internal {
        Types.Candidate[] memory candidates_ = new Types.Candidate[](4);

        // Gujarat
        candidates_[0] = Types.Candidate({
            name: "Chandra Babu Naidu",
            partyName: "TDP",
            nominationNumber: uint256(727477314982),
            stateCode: uint8(10),
            constituencyCode: uint8(1)
        });
        candidates_[1] = Types.Candidate({
            name: "Jagan Mohan Reddy",
            partyName: "YSRCP",
            nominationNumber: uint256(835343722350),
            stateCode: uint8(10),
            constituencyCode: uint8(1)
        });
        candidates_[2] = Types.Candidate({
            name: "G V Anjaneyulu",
            partyName: "TDP",
            nominationNumber: uint256(969039304119),
            stateCode: uint8(10),
            constituencyCode: uint8(2)
        });
        candidates_[3] = Types.Candidate({
            name: "Anil Kumar Yadav",
            partyName: "YSRCP",
            nominationNumber: uint256(429300763874),
            stateCode: uint8(10),
            constituencyCode: uint8(2)
        });

        for (uint256 i = 0; i < candidates_.length; i++) {
            candidate[candidates_[i].nominationNumber] = candidates_[i];
            candidates.push(candidates_[i]);
        }
    }

    function initializeVoterDatabase_() internal {
        // Gujarat
        voter[uint256(482253918244)] = Types.Voter({
            name: "Suresh",
            aadharNumber: uint256(482253918244),
            age: uint8(21),
            stateCode: uint8(10),
            constituencyCode: uint8(1),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(532122269467)] = Types.Voter({
            name: "Ramesh",
            aadharNumber: uint256(532122269467),
            age: uint8(37),
            stateCode: uint8(10),
            constituencyCode: uint8(1),
            isAlive: false,
            votedTo: uint256(0)
        });
        voter[uint256(468065932286)] = Types.Voter({
            name: "Mahesh",
            aadharNumber: uint256(468065932286),
            age: uint8(26),
            stateCode: uint8(10),
            constituencyCode: uint8(1),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(809961147437)] = Types.Voter({
            name: "Krishna",
            aadharNumber: uint256(809961147437),
            age: uint8(19),
            stateCode: uint8(10),
            constituencyCode: uint8(2),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(908623597782)] = Types.Voter({
            name: "Narendra",
            aadharNumber: uint256(908623597782),
            age: uint8(36),
            stateCode: uint8(10),
            constituencyCode: uint8(2),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(760344621247)] = Types.Voter({
            name: "Raghu",
            aadharNumber: uint256(760344621247),
            age: uint8(42),
            stateCode: uint8(10),
            constituencyCode: uint8(2),
            isAlive: true,
            votedTo: uint256(0)
        });
    }
}
