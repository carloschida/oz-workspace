## Purpose

This package is meant to replicate a (possible) bug in the package `zeppelin-solidity@1.6.0` regarding the `ERC827Token`.

Files of interest:
- `./contracts/TutorialToken.sol`
- `./UML/Tutorial Token inheritance.png`
- `./UML/Tutorial Token inheritance (simple).png`

## How to run

Install [Ganache](http://truffleframework.com/ganache/) (v1.0.2) and leave it running with the default mnemonic.

Install [Metamask](https://metamask.io/) for Chrome, Firefox, or Opera. Or use [Brave Browser](https://brave.com/) instead.

Install `truffle@4.0.6` (you may need `sudo`)
```
npm install --global truffle@4.0.6
``` 

Inside the repository folder run
```
truffle compile
truffle migrate
```

Run
```
npm run dev
```

Remember to open the application in `http://127.0.0.1:3000` with your Metamask-enabled browser.
Follow the instructions [here](http://truffleframework.com/tutorials/pet-shop#interacting-with-the-dapp-in-a-browser) to configure Metamask to use your local blockchain (Ganache's).


**The following lines describe the issue as published in [OpenZeppelin/zeppelin-solidity](https://github.com/OpenZeppelin/zeppelin-solidity/issues).**

## 🎉 Description

Assuming that the intention of the method `transfer(address _to, uint256 _value, bytes _data) public returns (bool)` of the `ERC827Token` interface is to handle ultimately the transfer of a token, and therefore its approval as well, I override it in my implementation but the behaviour does not math the expected result.
My guess is that it has to do with the inheritance of the contract (see `Tutorial Token inheritance (simple).png` and `Tutorial Token inheritance.png`).

- [X ] 🐛 This is a bug report.
- [ ] 📈 This is a feature request.

## 💻 Environment

zeppelin-solidity: 1.6.0
Ganache 1.0.2
Truffle v4.0.6 (core: 4.0.6)
Solidity v0.4.19 (solc-js)

## 📝 Details

Consider the final stage of the tutorial [Robust Smart Contracts with OpenZeppelin](http://truffleframework.com/boxes/tutorialtoken) that employs the [tutorialtoken truffle box](http://truffleframework.com/boxes/tutorialtoken).
So far everything works; truffle compiles it and migrates it.

Add properties to the contract such that tokens can be only transferred to pre-authorised addresses. For replicability I use the addresses generated by Ganache with the default mnemonic `candy maple cake sugar pudding cream honey rich smooth crumble sweet treat`.

Addresses of interest:
- A0 `0x627306090abaB3A6e1400e9345bC60c78a8BEf57` (contract deployer)
- A1 `0xf17f52151EbEF6C7334FAD080c5704D77216b732` (authorised address)
- A2 `0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef` (authorised address)
- A3 `0x821aEa9a577a9b44299B9c15c88cf3087F3b5544` (non-authorised address)

Override the method `transfer(address _to, uint256 _value, bytes _data) public returns (bool)` with the corresponding logic, ie, implement somewhere in the method `require(isAuthorized[_to])`.

Note that line 63 `./src/js/app.js` is the one that makes the call to the method
``return tutorialTokenInstance.transfer(toAddress, amount, {from: account});``

Transfers:
- A0 -> A1 (works and it should work)
- A0 -> A3 (works but it should **not** work)

## 🔢 Code To Reproduce Issue [ Good To Have ]

This code is what should be added/modified to the latest state of the [Robust Smart Contracts with OpenZeppelin](http://truffleframework.com/boxes/tutorialtoken).
A **repository containing the full code** can be found here but I still leave the additions for them to be more easily readable.

`TutorialToken.sol`:
```
 pragma solidity ^0.4.4;

import 'zeppelin-solidity/contracts/token/ERC827/ERC827Token.sol';

contract TutorialToken is ERC827Token { // No longer (only) `StandardToken`
    string public name = 'TutorialToken';
    string public symbol = 'TT';
    uint8 public decimals = 0;
    uint public INITIAL_SUPPLY = 1000000;

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
}
```

## 👍 Other Information

Note that if you additionally override the method `function transfer(address _to, uint256 _value) public returns (bool)` (attention to the signature) as follows, you obtain the desired result, ie, not being able to transfer to the non-authorised address A3.

```
function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(this));
    require(isAuthorized[_to]);
    super.transfer(_to, _value);
    return true;
}
```
This is why my guess is that someone the inheritance is wrong.
