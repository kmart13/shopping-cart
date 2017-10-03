pragma solidity ^0.4.17;

contract Owner {
  address public owner;

  // Ensures msg.sender is the `owner` of the contract.
  modifier onlyOwner() { assert(msg.sender == owner); _; }

  // Passing in owner address on construction. This is due the the way we are creating Cart and Inventory contracts. Since
  // they are being created from within the store contract, using msg.sender in the constructor would set owner to the
  // address of the calling function in Store. We want the address of the caller of the creation function. We accomplish this
  // by passing msg.sender from the calling function to the constructor.
  function Owner(address _owner) public { owner = _owner; }

  // Default payable fallback function to allow transfers
  function() public payable { }

  // Default suicide function
  function remove() public onlyOwner { selfdestruct(owner); }
}
