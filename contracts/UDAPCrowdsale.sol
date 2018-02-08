pragma solidity ^0.4.19;

import './Timelock.sol';
import './UPToken.sol';
import 'zeppelin-solidity/contracts/crowdsale/FinalizableCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/RefundableCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/Crowdsale.sol';

contract UDAPCrowdsale is CappedCrowdsale, RefundableCrowdsale {
  /**
   * @dev constructor
   * @param _startTime crowsale start time
   * @param _endTime crowdsale end time
   * @param _rate how many token units a buyer gets per wei
   * @param _goal the crowdsale minimum goal
   * @param _cap the maximum funds to be collected (in ETHER)
   */
  function UDAPCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _goal, uint256 _cap,
    address _wallet, UPToken _tokenContract)
    CappedCrowdsale(_cap)
    FinalizableCrowdsale()
    RefundableCrowdsale(_goal)
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    public {
      require(_goal <= _cap);
      token = _tokenContract;
  }

  function createTokenContract() internal returns (MintableToken) {
    return token;
  }

}
