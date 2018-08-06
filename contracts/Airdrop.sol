pragma solidity ^0.4.19;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract Airdrop is Ownable{

    ERC20 public token;
    uint256 public decimals;
    uint8 public maxCount = 50;
    address private wallet = "0xcabe9a163b96865308605bde13233fd1a0610931";

    constructor(ERC20 _token) public {
        require(_token != address(0));
        token = _token;
        decimals = _token.decimals();
    }

    /**
    * @dev perform a transfer of allocations
    * @param _recipients is a list of recipients
    * @param _tokens is a list of tokens
    */
    function airdropTokens(address[] _recipients,uint256[] _tokens) public onlyOwner {
        require(_recipients.length == _tokens.length);
        require(_recipients.length <= maxCount);

        for(uint256 i = 0; i< _recipients.length; i++)
        {
            if (_tokens[i] > 0) {
                token.transfer(_recipients[i], _tokens[i] * decimals);
            }
        }
    }

    function setMaxCount(uint8 _maxCount) public onlyOwner {
       maxCount =  _maxCount;
    }


    function withdraw() public onlyOwner {
        uint256 remaining = token.balanceOf(this);
        if (remaining > 0) {
            token.transfer(wallet, remaining);
        }
    }


}