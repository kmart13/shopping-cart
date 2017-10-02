pragma solidity ^0.4.17;

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
  event LogUpdate(string name, uint quantity);
  event LogRemove(string name);
  event LogPurchase(string, uint quantity, uint total);

  modifier validQuantity(uint _quantity) { require(_quantity > 0); _; }

  function Cart(address _owner) public Owner(_owner) {}

  function setInventory(address inventory) public onlyOwner {
    inv = Inventory(inventory);
  }

  function addItem(string _name, uint _quantity) public onlyOwner validQuantity(_quantity) {
    var (exists,) = getItem(_name);

    require(!exists);

    var (_price, _available) = inv.getItemInfo(_name);

    require(_quantity <= _available);

    cart[id++] = Item(_name, _price, _quantity);

    LogAdd(_name, _quantity);
  }

  function changeQuantity(string _name, uint _quantity) public onlyOwner validQuantity(_quantity) {
    var (exists, _id) = getItem(_name);
    require(exists);

    var (, _available) = inv.getItemInfo(_name);
    require(_quantity <= _available);

    cart[_id].quantity = _quantity;

    LogUpdate(_name, _quantity);
  }

  function removeItem(string _name) public onlyOwner {
    var (exists, _id) = getItem(_name);
    require(exists);

    delete cart[_id];

    LogRemove(_name);
  }

  function checkout() public payable onlyOwner {
    require((this.balance * 1 ether) >= (calculateTotal() * 1 ether));

    for (uint i = 0; i <= id; i++) {
      if (cart[i].quantity > 0) {
        var (_price, _available) = inv.getItemInfo(cart[i].name);
        require(cart[i].quantity <= _available);

        uint itemTotal = (cart[i].quantity * _price);

        if (address(inv).send((itemTotal* 1 ether))) {
          inv.buyItem(cart[i].name, cart[i].quantity);
          LogPurchase(cart[i].name, cart[i].quantity, itemTotal);
        }
      }
    }
  }

  function calculateTotal() public view returns (uint total) {
    total = 0;
    for (uint i = 0; i <= id; i++) {
      total += (cart[i].price * cart[i].quantity);
    }
  }

  function getItem(string _name) internal view returns (bool, uint) {
    for (uint i = 0; i <= id; i++) {
      if (keccak256(cart[i].name) == keccak256(_name)) {
        return (true, i);
      }
    }

    return (false, 0);
  }
}
