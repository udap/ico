pragma solidity ^0.4.19;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract Airdrop is Ownable{


    mapping(address => bool) public airdrops;

    ERC20 public tokenContract;

    constructor(ERC20 _tokenContract) public {
        require(_tokenContract != address(0));
        tokenContract = _tokenContract;
    }


    /**
    * @dev perform a transfer of allocations
    * @param _recipients is a list of recipients
    * @param _tokens is a list of tokens
    */
    function airdropTokens(address[] _recipients,uint256[] _tokens,bool allowMultiple) public  {
        require(_recipients.length == _tokens.length);

        for(uint8 i = 0; i< _recipients.length; i++){
            if (_tokens[i] > 0 && (allowMultiple || !airdrops[_recipients[i]]) ) {
                tokenContract.transferFrom(msg.sender,_recipients[i], _tokens[i]);
                airdrops[_recipients[i]] = true;
            }
        }
    }



}