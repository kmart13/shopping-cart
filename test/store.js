var Owner = artifacts.require("./Owner.sol");
var Store = artifacts.require("./Store.sol");
var Cart = artifacts.require("./Cart.sol");
var Inventory = artifacts.require("./Inventory.sol");

const web3 = global.web3;

contract('Store', function(accounts) {
  var store;
  var storeEvents;
  var inv;
  var invEvents;
  var cart;
  var cartEvents;
  var log;

  beforeEach(async function() {
    log = false;

    store = await Store.new({from: accounts[0]});

    storeEvents = store.allEvents(function(error, result) {
      if (!error && log)
        console.log(result);
    });

    await store.createInventory({from: accounts[1]});
    var addr = await store.getInventory({from: accounts[1]});
    inv = Inventory.at(addr);

    invEvents = inv.allEvents(function(error, result) {
      if (!error && log)
        console.log(result);
    });

    await store.createCart({from: accounts[2]});
    var addr = await store.getCart({from: accounts[2]});
    cart = Cart.at(addr);

    cartEvents = cart.allEvents(function(error, result) {
      if (!error && log)
        console.log(result);
    });
  });

  afterEach(function() {
    invEvents.stopWatching();
    cartEvents.stopWatching();
    storeEvents.stopWatching();
  });

  it("should create a new inventory", async function() {
    assert.equal(storeEvents.get()[0].event, "LogCreated", "The creation should have been logged");
  });

  it("should create a new shopping cart", async function() {
    assert.equal(storeEvents.get()[0].event, "LogCreated", "The creation should have been logged");
  });

  it("should allow interaction with inventory", async function() {
    await inv.addItem('Item1', 3, 5, {from: accounts[1]});
    var data = await inv.getItemInfo('Item1', {from: accounts[1]});
    assert.equal(data[0], 3, "The price should be 3");
    assert.equal(data[1], 5, "The quantity should be 5");
  });

  it("should allow interaction with cart", async function() {
    await inv.addItem('Item1', 3, 5, {from: accounts[1]});
    await inv.addItem('Item2', 5, 10, {from: accounts[1]});
    await cart.setInventory(inv.address, {from: accounts[2]});
    await cart.addItem('Item1', 2, {from: accounts[2]});
    assert.equal(cartEvents.get()[0].event, "LogAdd", "The iteme should be logged added");
    assert.equal(cartEvents.get()[0].args.name.valueOf(), 'Item1', "The name of item added should be Item1");
    assert.equal(cartEvents.get()[0].args.quantity.valueOf(), 2, "There should be 2 of this item added");
  });
});
