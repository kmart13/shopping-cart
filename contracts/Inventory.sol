pragma solidity ^0.4.17;

import "./Owner.sol";

contract Inventory is Owner {
  struct Item {
    string name;
    uint price;
    uint quantity;
    bool active;
  }

  uint private currentSku;

  mapping (uint => Item) public items;
  mapping (string => uint) internal lookup;

  event LogAdd(string name, uint price, uint quantity, uint sku);
  event LogUpdate(string name, uint price, uint quantity, uint sku);
  event LogStatusChange(string message, string name, uint sku);
  event LogWithdrawal(uint amount);

  modifier itemInInventory(string _name) { require(doesItemExist(_name)); _; }
  modifier itemNotInInventory(string _name) { require(!doesItemExist(_name)); _; }

  function Inventory(address _owner) public Owner(_owner) {
    currentSku = 1;
  }

  /// Add a new item with `_name` of item at `_price` in wei starting at `_quantity` to the inventory
  function addItem(string _name, uint _price, uint _quantity)
    public
    onlyOwner
    itemNotInInventory(_name)
  {
    uint itemSku = currentSku++;

    lookup[_name] = itemSku;
    items[itemSku] = Item(_name, _price, _quantity, true);

    LogAdd(_name, _price, _quantity, itemSku);
  }

  /// Update a specific item of `_name` with a new `_price` and `_quantity`
  function updateItem(string _name, uint _price, uint _quantity)
    public
    onlyOwner
    itemInInventory(_name)
  {
    uint itemSku = getSku(_name);

    items[itemSku].price = _price;
    items[itemSku].quantity = _quantity;

    LogUpdate(_name, _price, _quantity, itemSku);
  }

  /// Deactivate an item matching `_name` so that it may not be purchased
  function deactivateItem(string _name) public onlyOwner itemInInventory(_name) {
    uint itemSku = getSku(_name);

    items[itemSku].active = false;

    LogStatusChange("Deactivate", _name, itemSku);
  }

  /// Activate an item matching `_name` so that it may be purchased
  function activateItem(string _name) public onlyOwner itemInInventory(_name) {
    uint itemSku = getSku(_name);

    items[itemSku].active = true;

    LogStatusChange("Activate", _name, itemSku);
  }

  /// Delete an item matching `_name` from the inventory permanently
  function deleteItem(string _name) public onlyOwner itemInInventory(_name) {
    uint itemSku = getSku(_name);

    delete items[itemSku];
    delete lookup[_name];

    LogStatusChange("Delete", _name, itemSku);
  }

  /// Withdraw funds in the `_amount` of wei
  function withdrawFunds(uint _amount) public onlyOwner {
    require(_amount <= this.balance);

    msg.sender.transfer(_amount);

    LogWithdrawal(_amount);
  }

  function getItemInfo(string _name)
    public
    itemInInventory(_name)
    view returns (uint price, uint quantity)
  {
    uint itemSku = getSku(_name);

    price = items[itemSku].price;
    quantity = items[itemSku].quantity;
  }

  function isActive(string _name) public itemInInventory(_name) view returns (bool) {
    uint itemSku = getSku(_name);

    return items[itemSku].active;
  }

  function doesItemExist(string _name) public view returns (bool) {
    if (lookup[_name] != 0) {
      return true;
    } else {
      return false;
    }
  }

  function getBalance() public view returns (uint) {
    return this.balance;
  }

  function buyItem(string _name, uint _quantity) external {
    uint itemSku = getSku(_name);

    items[itemSku].quantity -= _quantity;
  }

  function getSku(string _name) internal itemInInventory(_name) view returns (uint) {
    return lookup[_name];
  }
}
