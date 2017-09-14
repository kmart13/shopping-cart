var Owner = artifacts.require("./Owner.sol");
var Cart = artifacts.require("./Cart.sol");
var Inventory = artifacts.require("./Inventory.sol");

const web3 = global.web3;

contract('Cart', function(accounts) {
  var cart;
  var inv;
  var invEvents;
  var cartEvents;
  var invLog;
  var cartLog;

  before(async function() {
    inv = await Inventory.new(accounts[0], {from: accounts[0]});
    await inv.addItem('Item1', 3, 5, {from: accounts[0]});
    await inv.addItem('Item2', 3, 5, {from: accounts[0]});
    await inv.addItem('Item3', 3, 5, {from: accounts[0]});

    cart = await Cart.new(accounts[1], {from: accounts[1]});
    await cart.setInventory(inv.address, {from: accounts[1]});
  });

  beforeEach(function() {
    invLog = false;
    cartLog = false;

    invEvents = inv.allEvents(function(error, result) {
      if (!error && invLog)
        console.log(result);
    });

    cartEvents = cart.allEvents(function(error, result) {
      if (!error && cartLog)
        console.log(result);
    });
  });

  afterEach(function() {
    invEvents.stopWatching();
    cartEvents.stopWatching();
  });

  it("should add items to the shopping cart", async function() {
    await cart.addItem('Item1', 4, {from: accounts[1]});
    assert.equal(cartEvents.get()[0].args.name.valueOf(), 'Item1', "The name of item added should be Item1");
    assert.equal(cartEvents.get()[0].args.quantity.valueOf(), 4, "There should be 4 of this item added");
  });

  it("should update item quantity in the shopping cart", async function() {
    await cart.changeQuantity('Item1', 5, {from: accounts[1]});
    assert.equal(cartEvents.get()[0].args.name.valueOf(), 'Item1', "The name of item updated should be Item1");
    assert.equal(cartEvents.get()[0].args.quantity.valueOf(), 5, "There should be 5 of this item now");
  });

  it("should remove items from the shopping cart", async function() {
    await cart.removeItem('Item1', {from: accounts[1]});
    assert.equal(cartEvents.get()[0].args.name.valueOf(), 'Item1', "Item1 should be removed from the cart");
  });

  it("should initiate the checkout process", async function() {
    await cart.addItem('Item1', 2, {from: accounts[1]});
    await cart.removeItem('Item1', {from: accounts[1]});
    await cart.addItem('Item1', 1, {from: accounts[1]});
    await cart.addItem('Item2', 1, {from: accounts[1]});
    await cart.changeQuantity('Item2', 2, {from: accounts[1]});
    await cart.addItem('Item3', 3, {from: accounts[1]});
    var total = web3.toWei(await cart.calculateTotal({from: accounts[1]}), "wei");
    console.log(total);
    await cart.checkout({from: accounts[1], value: total, gas: 150000});
    console.log(await inv.getBalance());
    console.log(cartEvents.get());
  });
});
