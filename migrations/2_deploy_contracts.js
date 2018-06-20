var UPToken = artifacts.require("./UPToken.sol");
var UDAPCrowdsale = artifacts.require("./UDAPCrowdsale.sol");

let _startTime = parseInt(new Date().getTime()/1000);
let _endTime = _startTime + 2*60;
let _rate = 15000;
let _goal = 10 * Math.pow(10,18);
let _cap = 20 * Math.pow(10,18);

let _initialSupply = 10000000000;
module.exports = function(deployer, network,accounts) {
   deployer.deploy(UPToken,_initialSupply).then(function(){
       let _wallet=accounts[accounts.length-3];
       let _token=UPToken.address;
       return deployer.deploy(UDAPCrowdsale,_startTime, _endTime,_rate,_goal,_cap,_wallet,UPToken.address);
   });
};
