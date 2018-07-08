pragma solidity ^0.4.19;
import 'zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract Privatesale is Ownable {

  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(address beneficiary,uint256 amount);
  event Revoked(address beneficiary,uint256 amount);

  struct ReleasePolicy {
    uint256 startTime;
    uint256 gapTime;
    uint256 releasePct;
  }

  // ERC20 basic token contract being held
  ERC20Basic public token;
  // beneficiaries
  address[] public beneficiaries;
  // release policies
  ReleasePolicy public policy;

  uint256 private totalAllocated;

  // map beneficiary address to TokenAllocation
  mapping(address => uint256) public tokenAllocated;
  // map a byte32 hash to uint256 (indicating released funds)
  // byte32 hash is generated using keccak256(beneficiary, releaseTime)
  mapping(address => uint256) public tokenReleased;


  constructor(ERC20Basic _token) public {
    require(_token != address(0));
    token = _token;
    policy = ReleasePolicy(now,300,15);
  }

  function addAllocation(address _beneficiary,uint256 _amount) public onlyOwner {
    require(_beneficiary != address(0));
    require(_amount > 0);
    require(policy.startTime > now);
    tokenAllocated[_beneficiary] = tokenAllocated[_beneficiary].add(_amount);
    totalAllocated = totalAllocated.add(_amount);
    _addBeneficiary(_beneficiary);
  }

  function _addBeneficiary(address _beneficiary) internal{
    if(tokenAllocated[_beneficiary] == 0){
        beneficiaries.push(_beneficiary);
    }
  }

  function getTotalAllocated() public onlyOwner returns (uint256) {
    return totalAllocated;
  }

  function calcTotalReleased() public returns(uint256){
    uint256 total = 0;
    for(uint i=0;i<beneficiaries.length;i++){
      total = total.add(tokenReleased[beneficiaries[i]]);
    }
    return total;
  }

  /**
  * @notice Allows the owner to revoke the vesting. Tokens already vested
  * remain in the contract, the rest are returned to the owner.
  */
  function revoke(address _beneficiary) public onlyOwner {
    uint256 unreleased = tokenAllocated[_beneficiary].sub(tokenReleased[_beneficiary]);
    require(unreleased > 0);

    token.safeTransfer(owner, unreleased);

    emit Revoked(_beneficiary,unreleased);
  }

  /**
 * @notice transfer token to owner
 */
  function collectionToken(uint256 _amount) public onlyOwner {
    uint256 currentBalance = token.balanceOf(this);
    require(currentBalance > _amount);
    token.safeTransfer(owner, _amount);
  }

  /**
* @notice transfer eth to owner
*/
  function collectionEth() public onlyOwner {
    owner.transfer(this.balance);
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   */
  function release(address _beneficiary) public {
    uint256 unreleased = releasableAmount(_beneficiary);

    require(unreleased > 0);

    tokenReleased[_beneficiary] = tokenReleased[_beneficiary].add(unreleased);

    token.safeTransfer(_beneficiary, unreleased);

    emit Released(_beneficiary,unreleased);
  }

  /**
  * @dev Calculates the amount that has already vested but hasn't been released yet.
  */
  function releasableAmount(address _beneficiary) public view returns (uint256) {
    return vestedAmount(_beneficiary).sub(tokenReleased[_beneficiary]);
  }

  /**
   * @dev Calculates the amount that has already vested.
   */
  function vestedAmount(address _beneficiary) public view returns (uint256) {
    if(now < policy.startTime){
        return 0;
    }else{
        uint256 _times = (now.sub(policy.startTime)).div(policy.gapTime);
        uint256 _totalPct = _times.mul(policy.releasePct);
        if(_totalPct > 100){
            return tokenAllocated[_beneficiary];
        }else{
            return tokenAllocated[_beneficiary].mul(_totalPct).div(100);
        }
    }
  }

  function () payable public {
    release(msg.sender);
  }


}
