var UPToken = artifacts.require("./UPToken.sol");
var Timelock = artifacts.require("./Timelock.sol");

module.exports = function(deployer) {
   deployer.deploy(UPToken).then(function(){
     return deployer.deploy(Timelock,UPToken.address);
   });
};
