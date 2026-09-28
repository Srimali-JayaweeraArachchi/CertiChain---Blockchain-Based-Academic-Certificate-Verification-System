const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CertiChain", function () {
  let c, admin, other;
  const H = ethers.keccak256(ethers.toUtf8Bytes("degree.pdf"));

  beforeEach(async () => {
    [admin, other] = await ethers.getSigners();
    c = await ethers.deployContract("CertiChain");
  });

  it("issues and verifies", async () => {
    await c.issueCertificate(H, "EG/2021/4661", "BSc Eng");
    const r = await c.verifyCertificate(H);
    expect(r.exists).to.equal(true);
    expect(r.revoked).to.equal(false);
  });

  it("blocks non-issuers", async () => {
    await expect(c.connect(other).issueCertificate(H, "x", "y"))
      .to.be.revertedWith("Not issuer");
  });

  it("blocks duplicates", async () => {
    await c.issueCertificate(H, "x", "y");
    await expect(c.issueCertificate(H, "x", "y")).to.be.revertedWith("Already issued");
  });

  it("revokes", async () => {
    await c.issueCertificate(H, "x", "y");
    await c.revokeCertificate(H);
    expect((await c.verifyCertificate(H)).revoked).to.equal(true);
  });

  it("unknown hash is not found", async () => {
    const r = await c.verifyCertificate(ethers.keccak256("0x1234"));
    expect(r.exists).to.equal(false);
  });
});