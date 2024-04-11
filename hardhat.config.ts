import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  defaultNetwork: "localhost",
  networks: {
    sepolia: {
      url: "https://sepolia.infura.io/v3/c8bd64b49111418bae05969e73c0f285",
      accounts: ["93a1fbb0f92d54ac8b83ac22b696c5a439a18f580c8f937f1728f90b639a2738"],
    },
  },
  etherscan: {
    apiKey: "G4ZP2P6UR64SFMYW7C2WW2EPWH1TR1JTYN",
  },
};

export default config;
