pragma solidity ^0.4.17;

import "./Owner.sol";
import "./Inventory.sol";
import "./Cart.sol";

contract Store is Owner {
  address constant DEFAULT_ADDRESS = 0x0;

  mapping (address => address) invens;
  mapping (address => address) carts;

  event LogCreated(string message, address contractAddress);
  event LogDeleted(string message, address contractAddress);

  // The `owner` of the store contract is `msg.sender`
  function Store() public Owner(msg.sender) {}

  /// User can create a new shopping cart assuming they do not already have a shopping cart in use
  function createCart() public {
    require(carts[msg.sender] == DEFAULT_ADDRESS);

    Cart cart = new Cart(msg.sender);

    address addr = address(cart);
    carts[msg.sender] = addr;

    LogCreated("Cart", addr);
  }

  /// User can create a new inventory assuming they do not already have an inventory in use
  function createInventory() public {
    require(invens[msg.sender] == DEFAULT_ADDRESS);

    Inventory inv = new Inventory(msg.sender);

    address addr = address(inv);
    invens[msg.sender] = addr;

    LogCreated("Inventory", addr);
  }

  // Returns the address of the `msg.sender` shopping cart contract
  function getCart() public view returns (address) {
    return carts[msg.sender];
  }

  // Returns the address of the `msg.sender` inventory contract
  function getInventory() public view returns (address) {
    return invens[msg.sender];
  }
}
