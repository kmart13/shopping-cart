var Inventory = artifacts.require("./Inventory.sol");

contract('Inventory', function(accounts) {
  var inven;

  it("should be owned by the creator", function() {
    return Inventory.deployed().then(function(instance) {
      inven = instance;
      return inven.owner();
    }).then(function(addr) {
      assert.equal(addr, accounts[0], "The creator is not the owner");
    });
  });
});
