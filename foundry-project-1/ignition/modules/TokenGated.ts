const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const TokenModule = buildModule("TokenModule", (m) => {
  const token = m.contract("TokenGated", ["0xE8E23e97Fa135823143d6b9Cba9c699040D51F70"]);

  return { token };
});

module.exports = TokenModule;
