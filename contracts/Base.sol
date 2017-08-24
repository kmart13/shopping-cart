pragma solidity ^0.4.15;

contract Base {
  address public owner;

  modifier onlyOwner() { assert(msg.sender == owner); _; }

  function Base() { owner = msg.sender; }

  function() { revert(); }

  function remove() onlyOwner { suicide(owner); }
}
