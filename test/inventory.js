var Inventory = artifacts.require("./Inventory.sol");

const web3 = global.web3;

contract('Inventory', function(accounts) {
  var inv;
  var events;
  var log;

  beforeEach(async function() {
    log = false;

    inv = await Inventory.new({from: accounts[0]});

    events = inv.allEvents(function(error, result) {
      if (!error && log)
        console.log(result);
    });
  });

  afterEach(function() {
    events.stopWatching();
  });

  it("should be owned by the creator", async function() {
    var addr = await inv.owner();
    assert.equal(addr, accounts[0], "The creator is not the owner");
  });

  it("should add an item to the inventory", async function() {
    await inv.addItem('Item1', 3, 5, {from: accounts[0]});
    var data = await inv.getItemInfo('Item1', {from: accounts[0]});
    assert.equal(data[0], 3, "The price should be 3");
    assert.equal(data[1], 5, "The quantity should be 5");
  });

  it("should update an item in the inventory", async function() {
    await inv.addItem('Item1', 3, 5, {from: accounts[0]});
    await inv.updateItem('Item1', 5, 10, {from: accounts[0]});
    var data = await inv.getItemInfo('Item1', {from: accounts[0]});
    assert.equal(data[0], 5, "The price should be 5");
    assert.equal(data[1], 10, "The quantity should be 10");
  });

  it("should manage active state of an item in inventory", async function() {
    await inv.addItem('Item1', 3, 5, {from: accounts[0]});
    var active = await inv.isActive('Item1', {from: accounts[1]});
    assert.equal(active, true, "The item should be active after adding");
    await inv.deactivateItem('Item1', {from: accounts[0]});
    var active = await inv.isActive('Item1', {from: accounts[1]});
    assert.equal(active, false, "The item should be deactivated");
    await inv.activateItem('Item1', {from: accounts[0]});
    var active = await inv.isActive('Item1', {from: accounts[1]});
    assert.equal(active, true, "The item should be activated");
  })

  it("should manage deletion of an item from the inventory", async function() {
    await inv.addItem('Item1', 3, 5, {from: accounts[0]});
    await inv.deleteItem('Item1', {from: accounts[0]});
    var exists = await inv.doesItemExist('Item1', {from: accounts[1]});
    assert.equal(exists, false, "The item should have been deleted");
    await inv.addItem('Item1', 5, 10, {from: accounts[0]});
    var data = await inv.getItemInfo('Item1', {from: accounts[0]});
    assert.equal(data[0], 5, "The price should be 5");
    assert.equal(data[1], 10, "The quantity should be 10");
  });
});
