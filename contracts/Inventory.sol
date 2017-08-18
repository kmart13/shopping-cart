pragma solidity ^0.4.11;

contract Inventory {
  address public owner;

  struct Item {
    string name;
    uint price;
    uint quantity;
    bool active;
    bool created;
  }

  uint itemSku;
  uint currentSku;

  mapping (string => uint) lookup;
  mapping (uint => Item) items;

  event Add(string message, string name, uint price, uint quantity, uint sku);
  event Update(string message, string name, uint price, uint quantity, uint sku);
  event StatusChange(string message, string name, uint sku);

  modifier onlyOwner() {
    assert(msg.sender == owner); _;
  }

  modifier itemInInventory(string _name) {
    require(doesItemNameExist(_name)); _;
  }

  modifier itemNotInInventory(string _name) {
    require(!doesItemNameExist(_name)); _;
  }

  function Inventory() {
    owner = msg.sender;
    currentSku = 1;
  }

  function() {
    revert();
  }

  function addItem(string _name, uint _price, uint _quantity)
    public
    onlyOwner
    itemNotInInventory(_name)
    returns (uint)
  {
    itemSku = currentSku++;
    items[itemSku] = Item(_name, _price, _quantity, true, true);
    lookup[_name] = itemSku;

    Add("Added Item", _name, _price, _quantity, itemSku);

    return itemSku;
  }

  function updateItem(string _name, uint _price, uint _quantity)
    public
    onlyOwner
    itemInInventory(_name)
    constant returns (bool)
  {
    itemSku = getSku(_name);

    items[itemSku].price = _price;
    items[itemSku].quantity = _quantity;

    Add("Updated Item", _name, _price, _quantity, itemSku);

    return true;
  }

  function deactivateItemByName(string _name) public onlyOwner itemInInventory(_name) {
    itemSku = getSku(_name);

    items[itemSku].active = false;

    StatusChange("Deactivated Item", _name, itemSku);
  }

  function activateItemByName(string _name) public onlyOwner itemInInventory(_name) {
    itemSku = getSku(_name);

    items[itemSku].active = true;

    StatusChange("Activated Item", _name, itemSku);
  }

  function deleteItemByName(string _name) public onlyOwner itemInInventory(_name) {
    itemSku = getSku(_name);

    delete items[itemSku];

    StatusChange("Deleted Item", _name, itemSku);
  }

  function isActive(string _name) public itemInInventory(_name) constant returns (bool) {
    itemSku = getSku(_name);

    return items[itemSku].active;
  }


  function getSku(string _name) internal itemInInventory(_name) constant returns (uint) {
    return lookup[_name];
  }

  function doesItemNameExist(string _name) internal constant returns (bool) {
    if (lookup[_name] != 0) {
      return true;
    } else {
      return false;
    }
  }

  function remove() onlyOwner {
    suicide(owner);
  }
}
