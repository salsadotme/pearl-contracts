// load dependencies
const { use, expect, assert } = require('chai');
const { ethers } = require("hardhat");

describe("Pearl", function () {

    let [admin, project1, project2] = ['', '', ''];
    let pearl;

    beforeEach(async function () {
        [admin, project1, project2] = await ethers.getSigners();
    })

    it('Pearl deploys.', async function() {
        const Pearl = await ethers.getContractFactory('Pearl');
        pearl = await Pearl.deploy('yamp.yamp.chat');
        await pearl.deployed();
    })

    it('Owner can set yamp server.', async function() {
        const project1Address = await project1.getAddress();
        console.log("project1Address: ", project1Address);
        await pearl.setYampServer(project1Address, 'project1.yamp.chat');
        const project1YampServer = await pearl.yampServers(project1Address);
        assert(project1YampServer == 'project1.yamp.chat', 'yamp server not set');
    })

    it("Check signature", async function () {
        const accounts = await ethers.getSigners(2)
    
        // const PRIV_KEY = "0x..."
        // const signer = new ethers.Wallet(PRIV_KEY)
        const signer = accounts[1]
        // const signer = project1Address
        const to = pearl.address
        const amount = 1
        const message = "Pearl message..."
        const nonce = 123
    
        const hash = await pearl.getMessageHash(to, amount, message, nonce)
        const sig = await signer.signMessage(ethers.utils.arrayify(hash))
    
        const ethHash = await pearl.getEthSignedMessageHash(hash)
    
        console.log("signer          ", signer.address)
        console.log("recovered signer", await pearl.recoverSigner(ethHash, sig))
    
        // Correct signature and message returns true
        expect(
          await pearl.verify(signer.address, to, amount, message, nonce, sig)
        ).to.equal(true)
    
        // Incorrect message returns false
        expect(
          await pearl.verify(signer.address, to, amount + 1, message, nonce, sig)
        ).to.equal(false)
      })

});
