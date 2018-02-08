pragma solidity ^0.4.19;

import './Timelock.sol';
import './UPToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract PreICO is Ownable {
  event TimelockCreated(address _timelock, address _beneficiary);
  event Log(bytes32 indexed msg, address indexed addr);
  uint256 public constant TEAM_TOKENS = 100*1000;
  // timelock contracts
  // Each timelock contract manages the timelock policies for a group of people
  mapping(bytes32 => Timelock) timelocks;
  UPToken upToken;
  uint32 due;

  function PreICO(UPToken _token) public {
    require(_token != address(0));
    upToken = _token;
    //due = _due;
  }

  /**
   * @dev addTimelock add a timelock contract to manage team tokens
   */
  function createTimelockFor(address _beneficiary, uint256 _amount) onlyOwner public returns (address){
    require(timelocks["team"]==address(0));
    Timelock _timelock = new Timelock(upToken);
    _timelock.addPolicy(now + 300, 40);
    _timelock.addPolicy(now + 600, 30);
    _timelock.addPolicy(now + 900, 30);
    _timelock.validatePolicies();
    _timelock.addBeneficiary(_beneficiary, _amount);

    upToken.mint(_timelock, _amount);
    timelocks["_name"] = _timelock;
    TimelockCreated(_timelock, _beneficiary);
    return _timelock;
  }

  function release() public {
    require(timelocks["team"] != address(0));
    Timelock _timelock = timelocks["team"];
    _timelock.release();
  }

  function () payable public {

  }
}
