pragma solidity ^0.4.15;

import "./Owner.sol";
import "./Inventory.sol";
import "./Cart.sol";

contract Store is Owner {
  address constant DEFAULT_ADDRESS = 0x0;

  mapping (address => address) invens;
  mapping (address => address) carts;

  event LogCreated(string message, address contractAddress);

  function Store() Owner(msg.sender) {}

  function createCart() public {
    require(carts[msg.sender] == DEFAULT_ADDRESS);

    Cart cart = new Cart(msg.sender);

    address addr = address(cart);
    carts[msg.sender] = addr;

    LogCreated("Cart", addr);
  }

  function createInventory() public {
    require(invens[msg.sender] == DEFAULT_ADDRESS);

    Inventory inv = new Inventory(msg.sender);

    address addr = address(inv);
    invens[msg.sender] = addr;

    LogCreated("Inventory", addr);
  }

  function getCart() public constant returns (address) {
    return carts[msg.sender];
  }

  function getInventory() public constant returns (address) {
    return invens[msg.sender];
  }
}
