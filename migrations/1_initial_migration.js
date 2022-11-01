const EVoting = artifacts.require("EVoting");
const Types = artifacts.require("Types");

module.exports = function (deployer, network) {
  if (network == "development") {
    deployer.deploy(Types);
    deployer.link(Types, EVoting);
    deployer.deploy(EVoting, 1662440960, 1667711360);
    // convert the time epoch of when voting ends & to UTC
    // START => Tuesday, September 6, 2022 10:39:20
    // END => Sunday, November 6, 2022 10:39:20
  } else {
    // For all other networks like live & test networks
    deployer.deploy(Types);
    deployer.link(Types, EVoting);
    deployer.deploy(EVoting, 1662440960, 1667711360);
  }
};
