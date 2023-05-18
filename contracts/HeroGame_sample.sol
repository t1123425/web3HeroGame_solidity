// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.18;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// Helper we wrote to encode in Base64
import "./libraries/Base64.sol";
import "hardhat/console.sol";

contract HeroGameSample is ERC721 {
    // 下列struct為腳色屬性，包含腳色id,名稱,圖片連結,生命值(HP),生命值上限(maxHp),攻擊力(attackDamage)
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;        
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

  // The tokenId is the NFTs unique identifier, it's just a number that goes
  //產生每個nft的獨立TokenID，這邊使用openzeppelin的counter函式，當每次呼叫就會+1
  // 0, 1, 2, 3, etc.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  //腳色陣列
  CharacterAttributes[] defaultCharacters;

  // We create a mapping from the nft's tokenId => that NFTs attributes.
  //這裡創建mapping來映射對應ID獲得合約內記錄創建的nft
  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

  // A mapping from an address => the NFTs tokenId. Gives me an ez way
  // to store the owner of the NFT and reference it later.
  //透過mapping從使用者的錢包地址來獲取nft tokenId，
  //並且將該nft的持有者儲存成nftHolders
  mapping(address => uint256) public nftHolders;

  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterAttackDmg
    // Below, you can also see I added some special identifier symbols for our NFT.
    // This is the name and symbol for our token, ex Ethereum and ETH. I just call mine
    // Heroes and HERO. Remember, an NFT is just a token!
  )
    ERC721("OWorldHeroes", "HERO")
  {
    for(uint i = 0; i < characterNames.length; i++) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
        maxHp: characterHp[i],
        attackDamage: characterAttackDmg[i]
      }));

      CharacterAttributes memory ca = defaultCharacters[i];
      
      // Hardhat's use of console.log() allows up to 4 parameters in any order of following types: uint, string, bool, address
      console.log("Done initializing %s w/ HP %s, img %s", ca.name, ca.hp, ca.imageURI);
    }

    // I increment _tokenIds here so that my first NFT has an ID of 1.
    // More on this in the lesson!
    _tokenIds.increment();
  }

  // Users would be able to hit this function and get their NFT based on the
  // characterId they send in!
  function mintCharacterNFT(uint _characterIndex) external {
    // Get current tokenId (starts at 1 since we incremented in the constructor).
    uint256 newItemId = _tokenIds.current();

    // The magical function! Assigns the tokenId to the caller's wallet address.
    _safeMint(msg.sender, newItemId);

    // We map the tokenId => their character attributes. More on this in
    // the lesson below.
    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].maxHp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage
    });

    console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);
    
    // Keep an easy way to see who owns what NFT.
    nftHolders[msg.sender] = newItemId;

    // Increment the tokenId for the next person that uses it.
    _tokenIds.increment();
  }
 
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
      CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

      string memory strHp = Strings.toString(charAttributes.hp);
      string memory strMaxHp = Strings.toString(charAttributes.maxHp);
      string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

      string memory json = Base64.encode(
        abi.encodePacked(
          '{"name": "',
          charAttributes.name,
          ' -- NFT #: ',
          Strings.toString(_tokenId),
          '", "description": "My name is',charAttributes.name,'Im a Hero of O-world, let me protect this world!", "image": "',
          charAttributes.imageURI,
          '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
          strAttackDamage,'} ]}'
        )
      );

      string memory output = string(
        abi.encodePacked("data:application/json;base64,", json)
      );
      
      return output;
  }
}

