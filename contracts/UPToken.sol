pragma solidity ^0.4.19;

import 'zeppelin-solidity/contracts/token/ERC20/CappedToken.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';

contract UPToken is CappedToken, Pausable {
  uint256 public constant TOTAL_AMOUNT = 500 * 1000 * 1000;

  string public constant name = "UDAP Token";
  string public constant symbol = "UP";

  // udap account address must be the creator of the token. Before deploying this
  // contract, we must update this value
  //address public udap = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;

  /**
   * @dev constructor the creator of the contract must be udap
   */
  function UPToken() CappedToken(TOTAL_AMOUNT) public {
    //require(msg.sender == udap);
  }

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }

  function mint(address _to, uint256 _amount) whenNotPaused public returns (bool) {
    return super.mint(_to, _amount);
  }
}
