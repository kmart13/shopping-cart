pragma solidity ^0.4.15;

contract Inventory {
  address public owner;

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

  event Add(string message, string name, uint price, uint quantity, uint sku);
  event Update(string message, string name, uint price, uint quantity, uint sku);
  event StatusChange(string message, string name, uint sku);

  modifier onlyOwner() { assert(msg.sender == owner); _; }
  modifier itemInInventory(string _name) { require(doesItemExist(_name)); _; }
  modifier itemNotInInventory(string _name) { require(!doesItemExist(_name)); _; }

  function Inventory() {
    owner = msg.sender;
    currentSku = 1;
  }

  function() { revert(); }

  function addItem(string _name, uint _price, uint _quantity)
    public
    onlyOwner
    itemNotInInventory(_name)
  {
    itemSku = currentSku++;

    lookup[_name] = itemSku;
    items[itemSku] = Item(_name, _price, _quantity, true);

    Add("Added Item", _name, _price, _quantity, itemSku);
  }

  function updateItem(string _name, uint _price, uint _quantity)
    public
    onlyOwner
    itemInInventory(_name)
  {
    itemSku = getSku(_name);

    items[itemSku].price = _price;
    items[itemSku].quantity = _quantity;

    Update("Updated Item", _name, _price, _quantity, itemSku);
  }

  function deactivateItem(string _name) public onlyOwner itemInInventory(_name) {
    itemSku = getSku(_name);

    items[itemSku].active = false;

    StatusChange("Deactivated Item", _name, itemSku);
  }

  function activateItem(string _name) public onlyOwner itemInInventory(_name) {
    itemSku = getSku(_name);

    items[itemSku].active = true;

    StatusChange("Activated Item", _name, itemSku);
  }

  function deleteItem(string _name) public onlyOwner itemInInventory(_name) {
    itemSku = getSku(_name);

    delete items[itemSku];
    delete lookup[_name];

    StatusChange("Deleted Item", _name, itemSku);
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

  function remove() onlyOwner { suicide(owner); }
}
