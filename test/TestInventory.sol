pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Inventory.sol";

contract TestInventory {
  Inventory inven = Inventory(DeployedAddresses.Inventory());

  function testInventoryCreation() {
    address expected = tx.origin;
    address owner = inven.owner();

    Assert.equal(owner, expected, "Inventory should be owned by the creator");
  }
}
