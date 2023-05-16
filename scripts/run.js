const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('HeroGame');
    const gameContract = await gameContractFactory.deploy(
      ["Iron man", "Spider Women", "Takeshi Kaneshiro"],       // Names
      ["https://i.imgur.com/8KfVht6.jpeg", // Images
      "https://i.imgur.com/rIMOnWm.jpeg", 
      "https://i.imgur.com/0dzpfWQ.jpeg"],
      [100, 200, 300],                    // HP values
      [100, 50, 25]
    );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);
};

const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log('Error:',error);
      process.exit(1);
    }
  };
  
  runMain();