// load dependencies
const { use, expect, assert } = require('chai');
const { ethers } = require("hardhat");

describe("NFTCollection", function () {

    let [admin, project1, project2] = ['', '', ''];
    let nftCollection;

    beforeEach(async function () {
        [admin, project1, project2] = await ethers.getSigners();
    })

    it('NftCollection deploys.', async function() {
        const NftCollection = await ethers.getContractFactory('NFTCollection');
        nftCollection = await NftCollection.deploy("PearlNFT", "PRL");
        await nftCollection.deployed();
        await nftCollection.setTokenURI("https://gateway.pinata.cloud/ipfs/QmbbA1YRjzSpSbUdaqoW1wiQU8MRYTaHK6fZPJCyWJEMpW/");
    })

    it('Owner can mint.', async function() {
        await nftCollection.mint();
        let tokenURI1 = await nftCollection.tokenURI(1);
        assert(tokenURI1 == 'https://gateway.pinata.cloud/ipfs/QmbbA1YRjzSpSbUdaqoW1wiQU8MRYTaHK6fZPJCyWJEMpW/1.json', 'something wrong with the collection');
    })

});
