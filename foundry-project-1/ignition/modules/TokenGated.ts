const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const TokenModule = buildModule("TokenModule", (m) => {
  const token = m.contract("TokenGated", ["0xE8E23e97Fa135823143d6b9Cba9c699040D51F70"]); // New one
  // const token = m.contract("TokenGated", ["0xf242cE588b030d0895C51C0730F2368680f80644"]);

  return { token };
});

module.exports = TokenModule;
