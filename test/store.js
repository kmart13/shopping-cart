var Base = artifacts.require("./Base.sol");
var Store = artifacts.require("./Store.sol");
var Inventory = artifacts.require("./Inventory.sol");
var Cart = artifacts.require("./Cart.sol");

const web3 = global.web3;

contract('Store', function(accounts) {
  var store;
  var events;
  var log;

  beforeEach(async function() {
    log = false;

    store = await Store.new({from: accounts[0]});

    events = store.allEvents(function(error, result) {
      if (!error && log)
        console.log(result);
    });
  });

  afterEach(function() {
    events.stopWatching();
  });

  it("should create a new inventory", async function() {
    await store.createInventory({from: accounts[1]});
    assert(true);
  });

  it("should create a new shopping cart", async function() {
    await store.createCart({from: accounts[1]});
    assert(true);
  });

  it("should allow interaction with inventory", async function() {
    await store.createInventory({from: accounts[1]});
    var addr = await store.getInventory({from: accounts[1]});
    var inv = Inventory.at(addr);
    await inv.addItem('Item1', 3, 5, {from: accounts[1]});
    var data = await inv.getItemInfo('Item1', {from: accounts[1]});
    assert.equal(data[0], 3, "The price should be 3");
    assert.equal(data[1], 5, "The quantity should be 5");
  });
});
