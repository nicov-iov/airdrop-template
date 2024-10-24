// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const AirdropManagerModule = buildModule("AirdropManagerModule", (m) => {
  const initialValues = [
    "0x6927ABD63Da2Da250E6676c64cF14586E1E1fA10",
  ]
  const initialAdmins = m.getParameter("initialAdmins", initialValues);

  const airdropManager = m.contract("AirdropManager", [initialAdmins]);

  return { airdropManager };
});

export default AirdropManagerModule;

