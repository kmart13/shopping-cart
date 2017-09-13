var Owner = artifacts.require("./Owner.sol");
var Inventory = artifacts.require("./Inventory.sol");
var Cart = artifacts.require("./Cart.sol");
var Store = artifacts.require("./Store.sol");

module.exports = function(deployer) {
  deployer.deploy(Owner);
  deployer.deploy(Inventory);
  deployer.deploy(Cart);
  deployer.deploy(Store);
};
