pragma solidity ^0.4.15;

import "./Owner.sol";
import "./Inventory.sol";

contract Cart is Owner {
  Inventory private inv;

  struct Item {
    string name;
    uint price;
    uint quantity;
  }

  uint private id;

  mapping (uint => Item) public cart;

  event LogAdd(string name, uint quantity);
  event LogRemove(string name, uint quantity);

  modifier validQuantity(uint _quantity) { require(_quantity > 0); _; }

  function Cart(address _owner) Owner(_owner) {}

  function setInventory(address inventory) public onlyOwner {
    inv = Inventory(inventory);
  }

  function addItem(string _name, uint _quantity) public onlyOwner validQuantity(_quantity) {
    var (_price, _available) = inv.getItemInfo(_name);

    require(_quantity <= _available);

    cart[id++] = Item(_name, _price, _quantity);

    LogAdd(_name, _quantity);
  }

  function removeItem(string _name, uint _quantity) public onlyOwner validQuantity(_quantity) {
    for (uint i = 0; i <= id; i++) {
      if (sha3(cart[i].name) == sha3(_name)) {
        require(_quantity <= cart[i].quantity);
        cart[i].quantity -= _quantity;

        LogRemove(_name, _quantity);

        break;
      }
    }
  }
}
