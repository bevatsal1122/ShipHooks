require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-foundry");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  networks: {
    sepolia: {
      accounts: ['0x' + ""],
      url: "https://eth-sepolia.g.alchemy.com/v2/s7T31oPGrY_VrwLVwRtcfCLO9Ag-7D4U"
    }
  }
};
