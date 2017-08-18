var Inventory = artifacts.require("./Inventory.sol");

const web3 = global.web3;

contract('Inventory', function(accounts) {
  var inv;
  var events;
  var log;

  beforeEach(function(done) {
    log = false;

    Inventory.new({from: accounts[0]}).then(function(instance) {
      inv = instance;

      events = inv.allEvents();

      events.watch(function(error, result) {
        if (!error && log)
          console.log(result.args);
      });

      done();
    });
  });

  afterEach(function() {
    events.stopWatching();
  });

  it("should be owned by the creator", function() {
    return inv.owner().then(function(addr) {
      assert.equal(addr, accounts[0], "The creator is not the owner");
    }).catch((err) => { throw new Error(err) });
  });

  it("should add an item to the inventory", function() {
    return inv.addItem('Item1', 3, 5, {from: accounts[0]}).then(function(sku) {
      assert(true);
    }).catch((err) => { throw new Error(err) });
  });

  it("should manage active state of an item in inventory", function() {
    return inv.addItem('Item1', 3, 5, {from: accounts[0]}).then(function(sku) {
      return inv.isActive('Item1');
    }).then(function(active) {
      assert.equal(active, true, "The item should be active after adding");
      return inv.deactivateItemByName('Item1');
    }).then(function() {
      return inv.isActive('Item1');
    }).then(function(active) {
      assert.equal(active, false, "The item should be deactivated");
      return inv.activateItemByName('Item1');
    }).then(function() {
      return inv.isActive('Item1');
    }).then(function(active) {
      assert.equal(active, true, "The item should be activated");
    }).catch((err) => { throw new Error(err) });
  })
});
