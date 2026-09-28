const hre = require("hardhat");
const fs = require("fs");

async function main() {
  const c = await hre.ethers.deployContract("CertiChain");
  await c.waitForDeployment();
  const address = await c.getAddress();
  const artifact = await hre.artifacts.readArtifact("CertiChain");
  fs.mkdirSync("frontend", { recursive: true });
  fs.writeFileSync("frontend/contract.json",
    JSON.stringify({ address, abi: artifact.abi }, null, 2));
  console.log("Deployed to", address);
}
main().catch((e) => { console.error(e); process.exitCode = 1; });