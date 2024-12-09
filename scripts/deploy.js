require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
    const signerAddress = process.env.SIGNER_ADDRESS;
    const PuzzleNFTCrafter = await ethers.getContractFactory("PuzzleNFTCrafterV5");
    console.log("Deploying PuzzleNFTCrafter...");
    const puzzleNFTCrafter = await PuzzleNFTCrafter.deploy(signerAddress);
    await puzzleNFTCrafter.waitForDeployment();
    console.log("Contract deployed at address:", await puzzleNFTCrafter.getAddress());
    console.log("Signer address set to:", signerAddress);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
