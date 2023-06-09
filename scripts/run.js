const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('HeroGame');
    const gameContract = await gameContractFactory.deploy();
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);
    // We only have three characters.
    // an NFT w/ the character at index of our array.
    //mintCharacterNFT param:名稱,圖片連結,生命值,生命值上限,攻擊力
    let txn = await gameContract.mintCharacterNFT('金城武','https://i.imgur.com/0dzpfWQ.jpeg','200','300');
    await txn.wait();

    // Get the value of the NFT's URI.
    let returnedTokenUri = await gameContract.tokenURI(1);
    console.log("Token URI:", returnedTokenUri);
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
  
  runMain()