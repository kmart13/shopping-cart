pragma solidity ^0.4.11;

contract Inventory {
  address public owner;

  struct Item {
    string name;
    uint price;
    uint quantity;
    bool active;
  }

  uint sku;

  mapping (string => uint) lookup;
  mapping (uint => Item) items;

  modifier onlyOwner() {
    assert(msg.sender != owner); _;
  }

  modifier itemInInventory(_name) {
    require(doesItemNameExist(_name)); _;
  }

  modifier itemNotInInventory(_name) {
    require(!doesItemNameExist(_name)); _;
  }

  function Inventory() {
    owner = msg.sender;
  }

  function() {
    throw;
  }

  function addItem(string _name, uint _price, uint _quantity)
    public
    onlyOwner
    itemNotInInventory(_name)
    constant returns (uint itemSku)
  {
    itemSku = sku++;
    items[itemSku] = Item(_name, _price, _quantity, true);
    lookup[_name] = itemSku;
  }

  function deactivateItemByName(string _name) public onlyOwner itemInInventory(_name) {
    items[getSku(_name)].active(false);
  }

  function getSku(string _name) internal itemInInventory(_name) constant returns (uint) {
    return lookup[_name];
  }

  function doesItemNameExist(string _name) internal constant returns (bool) {
    if (lookup[_name] != 0x0) {
      return true;
    } else {
      return false;
    }
  }

  function remove() onlyOwner {
    suicide(owner);
  }
}
