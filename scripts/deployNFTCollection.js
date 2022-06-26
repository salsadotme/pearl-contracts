
const hre = require("hardhat");

async function main() {

  // We get the contract to deploy

  const NftCollection = await hre.ethers.getContractFactory("NFTCollection");
  const nftCollection = await NftCollection.deploy("PearlNFT", "PRL");
  await nftCollection.deployed();

  console.log("NFTCollection deployed to:", nftCollection.address);

  await nftCollection.setTokenURI("https://gateway.pinata.cloud/ipfs/QmbbA1YRjzSpSbUdaqoW1wiQU8MRYTaHK6fZPJCyWJEMpW/");  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
