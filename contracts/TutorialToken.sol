pragma solidity ^0.4.17;

import 'zeppelin-solidity/contracts/token/ERC827/ERC827Token.sol';

contract TutorialToken is ERC827Token { // No longer (only) `StandardToken`
    string public name = 'TutorialToken';
    string public symbol = 'TT';
    uint8 public decimals = 2;
    uint public INITIAL_SUPPLY = 12000;

    mapping(address => bool) public isAuthorized;

    address[2] authorizedAddresses = [
        // 0x627306090abaB3A6e1400e9345bC60c78a8BEf57, // A0 (contract deployer also non-authorised address)
        0xf17f52151EbEF6C7334FAD080c5704D77216b732,    // A1 (authorised address)
        0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef     // A2 (authorised address)
        // 0x821aEa9a577a9b44299B9c15c88cf3087F3b5544  // A3 (non-authorised address)
    ];

    function TutorialToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        // Authorise addresses A1 and A2
        isAuthorized[authorizedAddresses[0]] = true;
        isAuthorized[authorizedAddresses[1]] = true;
    }

    function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
        require(_to != address(this));
        require(isAuthorized[_to]); // <- CRITICAL
        super.transfer(_to, _value);
        require(_to.call(_data));
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(this));
        require(isAuthorized[_to]);
        super.transfer(_to, _value);
        return true;
    }
}
