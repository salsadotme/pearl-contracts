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
        await pearl.setYampServer(project1Address, 'project1.yamp.chat');
        const project1YampServer = await pearl.yampServers(project1Address);
        assert(project1YampServer == 'project1.yamp.chat', 'yamp server not set');
    })

});
