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

contract HeroGame is ERC721{
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

    // We create a mapping from the nft's tokenId => that NFTs attributes.
    //這裡創建mapping來映射對應ID獲得合約內記錄創建的nft
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // A mapping from an address => the NFTs tokenId. Gives me an ez way
    // to store the owner of the NFT and reference it later.
    //透過mapping映射從使用者的錢包地址來獲取nft tokenId，
    //並且將該nft的持有者儲存成nftHolders
    mapping(address => uint256) public nftHolders;
    constructor()ERC721("O_WorldHeroes", "HERO"){
        console.log("I deploy O_world heros smart contract");
        // 當創建合約時這邊_tokenIds將會+1(預設counter會從0開始，而0在solidity為默認值)
        // 所以將下來創建NFT的第一支教穡將會從1開始
        _tokenIds.increment();
    }
    //創建NFT腳色，會需要入腳色NFT 名稱,圖片連結,(生命值/生命值上限),攻擊力
    function mintCharacterNFT(
        string memory Name,
        string memory ImageURI,
        uint Hp,
        uint AttackDamage) external{

        // 獲取當前_tokenId (初始會從1開始)
        uint256 newItemId = _tokenIds.current();
        // The magical function! Assigns the tokenId to the caller's wallet address.
        //根據newItemId 鑄造 NFT
        _safeMint(msg.sender, newItemId);

        //添加進遊戲腳色進入nftHolderAttributes的映射變量
         nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex:newItemId,
            name: Name,
            imageURI: ImageURI,
            hp: Hp,
            maxHp: Hp,
            attackDamage: AttackDamage
        });
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
          '", "description": "My name is ',charAttributes.name,' Im a Hero of the O-world !", "image": "',
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