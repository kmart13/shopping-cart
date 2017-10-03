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

  Item[] public cart;

  event LogAdd(string name, uint quantity);
  event LogUpdate(string name, uint quantity);
  event LogRemove(string name);
  event LogPurchase(string name, uint quantity, uint total);

  modifier validQuantity(uint _quantity) { require(_quantity > 0); _; }

  function Cart(address _owner) public Owner(_owner) {}

  /// Link cart to a specific `_inventory` address to purchase from
  function setInventory(address _inventory) public onlyOwner {
    inv = Inventory(_inventory);
  }

  /// Add new item `_name` in the amount of `_quantity` to your cart. There must be enough `_quantity` in the inventory.
  /// If item `_name` is already in the cart, use `changeQuantity` to modify.
  function addItem(string _name, uint _quantity) public onlyOwner validQuantity(_quantity) {
    var (exists,) = getItem(_name);

    require(!exists);

    var (_price, _available) = inv.getItemInfo(_name);

    require(_quantity <= _available);

    cart.push(Item(_name, _price, _quantity));

    LogAdd(_name, _quantity);
  }

  /// Change the quantity of item `_name` to new `_quantity` in your cart. There must be enough `_quantity` in the inventory.
  /// Item `_name` must be in your cart to change quantity.
  function changeQuantity(string _name, uint _quantity) public onlyOwner validQuantity(_quantity) {
    var (exists, _id) = getItem(_name);
    require(exists);

    var (, _available) = inv.getItemInfo(_name);
    require(_quantity <= _available);

    cart[_id].quantity = _quantity;

    LogUpdate(_name, _quantity);
  }

  /// Remove item `_name` from your cart. Item `_name` must be in your cart to remove.
  function removeItem(string _name) public onlyOwner {
    var (exists, _id) = getItem(_name);
    require(exists);

    delete cart[_id];

    LogRemove(_name);
  }

  // Before transferring wei, the quantity remaining in the linked inventory is checked.
  /// Payable in the amount of `calculateTotal()` in wei, to purchase items in your cart.
  function checkout() public payable onlyOwner {
    require((this.balance) >= (calculateTotal()));

    for (uint i = 0; i < cart.length; i++) {
      if (cart[i].quantity > 0) {
        var (_price, _available) = inv.getItemInfo(cart[i].name);
        require(cart[i].quantity <= _available);

        uint itemTotal = (cart[i].quantity * _price);

        if (address(inv).send((itemTotal))) {
          inv.purchaseItem(cart[i].name, cart[i].quantity);
          LogPurchase(cart[i].name, cart[i].quantity, itemTotal);
          delete cart[i];
        }
      }
    }
  }

  // Returns the total in wei of all items in your cart
  function calculateTotal() public view returns (uint total) {
    total = 0;
    for (uint i = 0; i < cart.length; i++) {
      total += (cart[i].price * cart[i].quantity);
    }
  }

  // Finds the index of item `_name` in the cart if it exists.
  function getItem(string _name) internal view returns (bool, uint) {
    for (uint i = 0; i < cart.length; i++) {
      if (keccak256(cart[i].name) == keccak256(_name)) {
        return (true, i);
      }
    }

    return (false, 0);
  }
}
