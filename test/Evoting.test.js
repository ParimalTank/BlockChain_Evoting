let EVoting = artifacts.require("EVoting");

contract(
  "EVoting",
  (async = (accounts) => {
    let chief = accounts[0];

    it("Contract Deployed", async () => {
      let evc = await EVoting.deployed();
      let electionChief = await evc.electionChief();
      let electionStart = await evc.votingStartTime();
      let electionEnd = await evc.votingEndTime();

      assert.notEqual(evc.address, 0x0, "Has Contract Address");
      assert.equal(electionChief, chief, "Not Chief");
      assert.equal(
        electionStart.toNumber(),
        1662440960,
        "Start Time not: (1662440960) Tuesday, September 6, 2022 10:39:20"
      );
      assert.equal(
        electionEnd.toNumber(),
        1667711360,
        "End Time not: (1667711360) Sunday, November 6, 2022 10:39:20"
      );
    });

    it("candidate", async () => {
      let evc = await EVoting.deployed();
      let voter = accounts[1];

      let actualCandidate = [
        ["Chandra Babu Naidu", "TDP", "727477314982", "10", "1"],
        ["Jagan Mohan Reddy", "YSRCP", "835343722350", "10", "1"],
      ];

      let candidateList = await evc.getCandidateList(532122269467, {
        from: voter,
      });
      assert.equal(
        candidateList.length,
        actualCandidate.length,
        "Candidate List not empty"
      );
    });

    it("Voter Tests", async () => {
      let evc = await EVoting.deployed();
      let voter = accounts[1];

      let isEligible = await evc.isVoterEligible(727938171119, { from: voter });
      assert.equal(isEligible, false, "Should not be elegible");

      let isAlive = await evc.isVoterEligible(756623869645, { from: voter });
      assert.equal(isAlive, false, "Should be elegible");

      let didVoted = await evc.didCurrentVoterVoted(532122269467, {
        from: voter,
      });
      // console.log(didVoted);
      assert.equal(didVoted.userVoted_, false, "Should not have voted");

      await evc.vote(727477314982, 468065932286, 1666365324, {
        from: voter,
      });

      didVoted = await evc.didCurrentVoterVoted(468065932286, {
        from: voter,
      });
      assert.equal(didVoted.userVoted_, true, "Should have voted");
    });

    it("Result", async () => {
      let evc = await EVoting.deployed();

      // constituency: 1
      await evc.vote(835343722350, 482253918244, 1666365324, {
        from: accounts[3],
      });

      // constituency: 2
      await evc.vote(969039304119, 760344621247, 1666365324, {
        from: accounts[4],
      });
      await evc.vote(429300763874, 908623597782, 1666365324, {
        from: accounts[5],
      });
      await evc.vote(429300763874, 809961147437, 1666365324, {
        from: accounts[6],
      });

      let res = await evc.getResults(1767711360, { from: accounts[1] });
      // console.log(res);
      assert.equal(res.length, 4, "Should have 4 results");
    });
  })
);
