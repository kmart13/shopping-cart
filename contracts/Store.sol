pragma solidity ^0.4.15;

import "./Base.sol";
import "./Inventory.sol";
import "./Cart.sol";

contract Store is Base {
  address constant DEFAULT_ADDRESS = 0x0000000000000000000000000000000000000000;

  mapping (address => address) invens;
  mapping (address => address) carts;

  event Created(string message, address contractAddress);

  function createCart() public {
    require(carts[msg.sender] == DEFAULT_ADDRESS);

    Cart cart = new Cart();

    address addr = address(cart);
    carts[msg.sender] = addr;

    Created("Cart", addr);
  }

  function createInventory() public {
    require(invens[msg.sender] == DEFAULT_ADDRESS);

    Inventory inv = new Inventory();

    address addr = address(inv);
    invens[msg.sender] = addr;

    Created("Inventory", addr);
  }

  function getCart() public constant returns (address) {
    return carts[msg.sender];
  }

  function getInventory() public constant returns (address) {
    return invens[msg.sender];
  }
}
