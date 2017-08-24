var Base = artifacts.require("./Base.sol");
var Inventory = artifacts.require("./Inventory.sol");
var ShoppingCart = artifacts.require("./ShoppingCart.sol");

module.exports = function(deployer) {
  deployer.deploy(Base);
  deployer.deploy(Inventory);
  deployer.deploy(ShoppingCart);
};
