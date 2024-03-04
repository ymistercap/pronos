async function main() {
  const SmartBet = await ethers.getContractFactory("SmartBet");
  console.log("Deploying SmartBet...");
  const smartBet = await SmartBet.deploy();
  await smartBet.deployed();
  console.log("SmartBet deployed to:", smartBet.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
