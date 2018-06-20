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
       /*uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _goal,
           uint256 _cap, address _wallet, ERC20 _token*/
       let _wallet=accounts[accounts.length-1];
       let _token=UPToken.address;
       return deployer.deploy(UDAPCrowdsale,_startTime, _endTime,_rate,_goal,_cap,_wallet,UPToken.address);
   });
};
