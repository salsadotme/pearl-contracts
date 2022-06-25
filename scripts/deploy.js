
const hre = require("hardhat");

async function main() {

  // We get the contract to deploy
  const Pearl = await hre.ethers.getContractFactory("Pearl");
  const pearl = await Pearl.deploy("yamp.yamp.chat");

  await pearl.deployed();

  console.log("Pearl deployed to:", pearl.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
