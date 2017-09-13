pragma solidity ^0.4.15;

contract Owner {
  address public owner;

  modifier onlyOwner() { assert(msg.sender == owner); _; }

  function Owner(address _owner) { owner = _owner; }

  function() { revert(); }

  function remove() onlyOwner { suicide(owner); }
}
