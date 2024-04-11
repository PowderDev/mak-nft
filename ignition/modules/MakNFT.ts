import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import dotenv from "dotenv";
dotenv.config();

const VRF_COORDINATOR = process.env.VRF_COORDINATOR;
const SUB_ID = process.env.SUB_ID;
const GAS_LANE = process.env.GAS_LANE;
const CALLBACK_GAS_LIMIT = process.env.CALLBACK_GAS_LIMIT;
const BASE_URI = process.env.BASE_URI;
const MSC_ADDRESS = process.env.MSC_ADDRESS;

const MakNFTModule = buildModule("MakNFTModule", (m) => {
  const makNFT = m.contract("MakNFT", [
    VRF_COORDINATOR,
    SUB_ID,
    GAS_LANE,
    CALLBACK_GAS_LIMIT,
    BASE_URI,
    MSC_ADDRESS,
  ]);

  return { makNFT };
});

export default MakNFTModule;
