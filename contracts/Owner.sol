pragma solidity ^0.4.15;

contract Base {
  address public owner;

  modifier onlyOwner() { assert(tx.origin == owner); _; }

  function Base() { owner = tx.origin; }

  function() { revert(); }

  function remove() onlyOwner { suicide(owner); }
}
