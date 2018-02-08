pragma solidity ^0.4.19;

import 'zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

/**
 * Timelock is a contract that holds and releases tokens based on pre-defined
 * release policies
 */
contract Timelock is Ownable {

  using SafeERC20 for ERC20Basic;

  event TokenReleased(uint indexed period, uint256 indexed tokens);
  event Log(bytes32 indexed msg, uint indexed val);

  struct ReleasePolicy {
    uint256 releaseTime;
    uint256 releasePct;
  }

  // ERC20 basic token contract being held
  ERC20Basic public token;
  // total locked amount
  uint256 lockedAmount;
  // release policies
  ReleasePolicy[] policies;
  // beneficiaries
  address[] beneficiaries;
  // map beneficiary address to TokenAllocation
  mapping(address => uint256) tokenAllocated;
  // map a byte32 hash to uint256 (indicating released funds)
  // byte32 hash is generated using keccak256(beneficiary, releaseTime)
  mapping(bytes32 => uint256) tokenReleased;

  /**
   * @dev constructor a timelock contract stores funds that will be distributed to
   * a group of beneficiaries based on pre-defined release policies
   * @param _token an ERC20Basic tokens
   */
  function Timelock(address _token) public {
    //require(validPolicies(_policies));
    token = ERC20Basic(_token);
  //  policies = _policies;
  }

  function validatePolicies() public view returns (bool) {
    uint pct = 0;
    uint256 checkTime = 0;
    for (uint i=0 ;i<policies.length; i++) {
      if (policies[i].releaseTime <= now || policies[i].releaseTime < checkTime
        || policies[i].releasePct == 0) return false;
      checkTime = policies[i].releaseTime;
      pct += policies[i].releasePct;
    }
    return (pct == 100);
  }

  function addPolicy(uint256 _releaseTime, uint256 _releasePct) public returns (bool) {
      require(_releaseTime > now && _releasePct > 0 && _releasePct <= 100);
      Log("policy",_releaseTime);
      policies.push(ReleasePolicy(_releaseTime,_releasePct));
  }

  // add beneficiary to timelock
  function addBeneficiary(address _beneficiary, uint256 _amount) onlyOwner public {
    require(tokenAllocated[_beneficiary] == 0 && _amount > 0);
    tokenAllocated[_beneficiary] = _amount;
    lockedAmount += _amount;
  }

  function getEffectivePeriod() internal view returns (uint) {
    for (uint i=policies.length-1; i>=0; i--) {
      if (now >= policies[i].releaseTime) {
        break;
      }
    }
    return i;
  }

  /**
   * @notice Transfers tokens held by timelock to all beneficiaries.
   */
  function release() onlyOwner public returns (bool) {
    uint period = getEffectivePeriod();
    Log("check period",period);
    require(period >= 0 && period < policies.length);
    // validate balance and transfer
    uint256 amount = token.balanceOf(this);
    // total amount to be released in this period
    uint256 toBeReleased = lockedAmount * policies[period].releasePct / 100;
    require(amount >= toBeReleased && amount > 0);
    //policies[period].released = true;
    uint256 alreadyReleased = 0;
    for(uint i=0; i<beneficiaries.length; i++) {
      uint256 toBeTransferred = tokenAllocated[beneficiaries[i]];
      // have we release the fund to this beneficiary?
      bytes32 releaseHash = keccak256(beneficiaries[i], policies[period].releaseTime);
      if (tokenReleased[releaseHash] == 0) {
        tokenReleased[releaseHash] = toBeTransferred;
        Log("transfer",toBeTransferred);
        token.safeTransfer(beneficiaries[i], toBeTransferred);
      }
      alreadyReleased += tokenReleased[releaseHash];
    }
    TokenReleased(period, alreadyReleased);
    return (toBeReleased == alreadyReleased);
  }
}
