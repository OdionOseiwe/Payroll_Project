import { ethers } from "hardhat";
import   "@nomiclabs/hardhat-ethers"
import "@nomicfoundation/hardhat-toolbox";

import MerkleTree from 'merkletreejs';
import keccak256 from 'keccak256';

async function main() {
    const signers = [
      "0xe5cd92f88c2e6659de23944985eba50628318c9b",
      "0x626e3Fa07728FEf9b1FC3306866A906b51034d22",
      "0x02f84a56e4ebba0f7840aab2664ad1c8476b5ed5",
      "0xD909b78898AE965C90bb57056da4B18a00582d0E"
    ]

    // const signers = await ethers.getSigners();
  
    const leafNodes = signers.map(signer => keccak256(signer));
    const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
  
    const rootHash = merkleTree.getHexRoot();
  
    console.log("merkletree", merkleTree.toString());
    console.log("Root Hash: ", rootHash);


    const claimingAddress = signers[0];

    const hexProof = merkleTree.getHexProof(keccak256(claimingAddress));
    console.log("proof", hexProof);

    console.log(claimingAddress, "im claiming");
    

    console.log("deploying....");

    const [add1] = await ethers.getSigners();

    console.log(add1.address);
    
  
    
    const Merkleprove = await ethers.getContractFactory("Payroll");
    const merkleprove = await Merkleprove.deploy();

    const add = await merkleprove.deployed();

    console.log("deployed to:", add.address);
    
    
    await merkleprove.withdraw(hexProof);
  
     
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
