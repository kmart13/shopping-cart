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
    }).then(done).catch(done);
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
    return inv.addItem('Item1', 3, 5, {from: accounts[0]}).then(function() {
      assert.equal(events.get()[0].args.name.valueOf(), 'Item1', "The name should be Item1");
      assert.equal(events.get()[0].args.price.valueOf(), 3, "The price should be 3");
      assert.equal(events.get()[0].args.quantity.valueOf(), 5, "The quantity should be 5");
      return inv.getItemInfo('Item1');
    }).then(function(data) {
      assert.equal(data[0], 3, "The price should be 3");
      assert.equal(data[1], 5, "The quantity should be 5");
    }).catch((err) => { throw new Error(err) });
  });

  it("should update an item in the inventory", function() {
    log = true;
    return inv.addItem('Item1', 3, 5, {from: accounts[0]}).then(function() {
      return inv.updateItem('Item1', 5, 10, {from: accounts[0]});
    }).then(function() {
      //Event logging doesn't appear to be completely functional...
      return inv.getItemInfo('Item1');
    }).then(function(data) {
      assert.equal(data[0], 5, "The price should be 5");
      assert.equal(data[1], 10, "The quantity should be 10");
    }).catch((err) => { throw new Error(err) });
  });

  it("should manage active state of an item in inventory", function() {
    return inv.addItem('Item1', 3, 5, {from: accounts[0]}).then(function(sku) {
      return inv.isActive('Item1');
    }).then(function(active) {
      assert.equal(active, true, "The item should be active after adding");
      return inv.deactivateItem('Item1');
    }).then(function() {
      return inv.isActive('Item1');
    }).then(function(active) {
      assert.equal(active, false, "The item should be deactivated");
      return inv.activateItem('Item1');
    }).then(function() {
      return inv.isActive('Item1');
    }).then(function(active) {
      assert.equal(active, true, "The item should be activated");
    }).catch((err) => { throw new Error(err) });
  })
});
