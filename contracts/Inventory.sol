pragma solidity ^0.4.15;

import "./Owner.sol";

contract Inventory is Owner {
  struct Item {
    string name;
    uint price;
    uint quantity;
    bool active;
  }

  uint private itemSku;
  uint private currentSku;

  mapping (uint => Item) public items;
  mapping (string => uint) internal lookup;

  event LogAdd(string message, string name, uint price, uint quantity, uint sku);
  event LogUpdate(string message, string name, uint price, uint quantity, uint sku);
  event LogStatusChange(string message, string name, uint sku);

  modifier itemInInventory(string _name) { require(doesItemExist(_name)); _; }
  modifier itemNotInInventory(string _name) { require(!doesItemExist(_name)); _; }

  function Inventory(address _owner) Owner(_owner) {
    currentSku = 1;
  }

  function addItem(string _name, uint _price, uint _quantity)
    public
    onlyOwner
    itemNotInInventory(_name)
  {
    itemSku = currentSku++;

    lookup[_name] = itemSku;
    items[itemSku] = Item(_name, _price, _quantity, true);

    LogAdd("Added Item", _name, _price, _quantity, itemSku);
  }

  function updateItem(string _name, uint _price, uint _quantity)
    public
    onlyOwner
    itemInInventory(_name)
  {
    itemSku = getSku(_name);

    items[itemSku].price = _price;
    items[itemSku].quantity = _quantity;

    LogUpdate("Updated Item", _name, _price, _quantity, itemSku);
  }

  function deactivateItem(string _name) public onlyOwner itemInInventory(_name) {
    itemSku = getSku(_name);

    items[itemSku].active = false;

    LogStatusChange("Deactivated Item", _name, itemSku);
  }

  function activateItem(string _name) public onlyOwner itemInInventory(_name) {
    itemSku = getSku(_name);

    items[itemSku].active = true;

    LogStatusChange("Activated Item", _name, itemSku);
  }

  function deleteItem(string _name) public onlyOwner itemInInventory(_name) {
    itemSku = getSku(_name);

    delete items[itemSku];
    delete lookup[_name];

    LogStatusChange("Deleted Item", _name, itemSku);
  }

  function getItemInfo(string _name)
    public
    itemInInventory(_name)
    constant returns (uint price, uint quantity)
  {
    itemSku = getSku(_name);

    price = items[itemSku].price;
    quantity = items[itemSku].quantity;
  }

  function isActive(string _name) public itemInInventory(_name) constant returns (bool) {
    itemSku = getSku(_name);

    return items[itemSku].active;
  }

  function doesItemExist(string _name) public constant returns (bool) {
    if (lookup[_name] != 0) {
      return true;
    } else {
      return false;
    }
  }

  function getSku(string _name) internal itemInInventory(_name) constant returns (uint) {
    return lookup[_name];
  }
}
