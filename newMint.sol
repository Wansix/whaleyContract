// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hc_whitelists.sol";
import "Mint.sol";

contract MintNewWhaleyProject is ERC721Enumerable, Ownable{
    struct NFTCounts{        
        uint public1;
        uint public2;
    }        
     /* Init                0
        Whitelist1          1 
        WaitingWhitelist2   2 
        Whitelist2          3 
        WaitingPublic1      4
        Public1             5,
        WaitingPublic2      6,
        Public2             7, 
        Done                8 */
    enum Phase {Init, Whitelist1, WaitingWhitelist2, Whitelist2, WaitingPublic1, Public1, WaitingPublic2, Public2, Done}
    Phase public currentPhase = Phase.WaitingPublic1;       
    string public notRevealedURI = "https://bafkreiendtq6ojbhhyvcyqjm6c5buabp5aiwrgwfgbd2x7zztdez2esq5e.ipfs.nftstorage.link";
    string public metadataURI = "https://nftstorage.link/ipfs/bafybeigimlc4ms54uu5u6s2yy4wv4x46klolmt7cmborcumiv4gxrrwz74";        
    bool public isRevealed = false;

    // uint256 public mintPrice;
    uint256 public totalSaleNFTAmount = 77;  // 777개
    uint256 public totalNFTAmount = 100;   // 1000개
    address public mintDepositAddress;   
    
    uint256 public public1SaleAmount = 15; // public1 물량 150개
    uint256 public public2SaleAmount = 47; // public2 물량 477개 test check    
    
    uint256 public public1SaleAvailableAmount = public1SaleAmount;
    uint256 public public2SaleAvailableAmount = public2SaleAmount;    
    uint256 public public1SaleLimit = 1;
    uint256 public public2SaleLimit = 15;
    uint256 public maxTransaction = 3;
    
    mapping (Phase => uint256) public mintPriceList;
    mapping (address => bool) public admin;
    mapping (address => NFTCounts) public NFTCountsList;
    
    MintWhaleyProject public mintWhaleyProject;

    address public mintWhaleyProejctAddress = 0x20AbDEA8Db0271688534EF26b503Da8Bf55a59F0;  
    uint256 public airDropNum = 1;
    
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        mintDepositAddress = owner();
        admin[owner()] = true;                
        mintWhaleyProject = MintWhaleyProject(mintWhaleyProejctAddress);
    }

    function airDrop() public onlyOwner {
        uint256 tokenIndex = airDropNum+1;
        address to = mintWhaleyProject.ownerOf(tokenIndex);
        transferFrom(owner(),to,airDropNum++); 
    }
    function batchAirDrops(uint _amount) public onlyOwner{
        for(uint i = 0; i < _amount; i++) {
            airDrop();
        }
    }


    function setMintPrice(Phase phase,uint256 _mintPrice) public {
        require(admin[msg.sender], "Caller is not admin");
        mintPriceList[phase] = _mintPrice; 
    }

    function advancePhase() public {
        require(admin[msg.sender], "Caller is not admin");
        if(currentPhase != Phase.Done){
            uint nextPhase = uint(currentPhase) + 1;
            currentPhase = Phase(nextPhase);            

            if(currentPhase == Phase.Public2)
            {
                public2SaleAvailableAmount += public1SaleAvailableAmount;                 
                public1SaleAvailableAmount = 0;                
            }            
        }
    }
    function backPhase() public {
        require(admin[msg.sender], "Caller is not admin");
        if(currentPhase != Phase.Init){
            uint nextPhase = uint(currentPhase) - 1;
            currentPhase = Phase(nextPhase);
        }
    }

    function setAdmin(address _address) public onlyOwner{
        admin[_address] = true;
    } 

    function mintNFT_Owner() public {
        require(admin[msg.sender], "Caller is not admin");        
        require(totalSupply() < totalNFTAmount, "You can no longer mint NFT."); 
        uint tokenId = totalSupply() + 1;
        _mint(msg.sender, tokenId);
    }

    function batchMintNFT_Owner(uint _amount) public {   
        for(uint i = 0; i < _amount; i++) {
            mintNFT_Owner();
        }
    }
    function mintNFT() private { 
        uint tokenId = totalSupply() + 1;
        if(currentPhase == Phase.Public1)
        {
            NFTCountsList[msg.sender].public1++;
            public1SaleAvailableAmount--;
        }
        else if(currentPhase == Phase.Public2)
        {
            NFTCountsList[msg.sender].public2++;
            public2SaleAvailableAmount--;
        }        
        _mint(msg.sender, tokenId);        
    }   

    function batchMintNFT(uint _amount) public payable{  
        require((currentPhase>=Phase.Whitelist1 && currentPhase<=Phase.Public2),"no mint stage");
        require((totalSupply() + _amount) <= totalSaleNFTAmount, "You can no longer mint NFT.");   
        require(msg.value >= (mintPriceList[currentPhase]*_amount), "Not enough matic.");
        require(_amount <= maxTransaction, "Over max transaction");
        require(currentPhase==Phase.Public1 || currentPhase==Phase.Public2,"no mint stage");
        
        if(currentPhase == Phase.Public1)
        {          
            require(public1SaleAvailableAmount > 0, "no amount! sold out!");
            require((NFTCountsList[msg.sender].public1 + _amount) <= public1SaleLimit, "public1 limit!");
        }
        else if(currentPhase == Phase.Public2)
        {                     
            require(public2SaleAvailableAmount > 0, "no amount! sold out!");
            require((NFTCountsList[msg.sender].public2 + _amount) <= public2SaleLimit, "public2 limit!");           
        }  
      
        for(uint i = 0; i < _amount; i++) {
            mintNFT();
        }
        payable(mintDepositAddress).transfer(msg.value);
    }

    function tokenURI(uint _tokenId) override public view returns (string memory) {
        if(isRevealed == false) {
            return notRevealedURI;
        }
       
        return string(abi.encodePacked(metadataURI, '/', Strings.toString(_tokenId), '.json'));
    }

    function setTokenURI(string memory _metadataURI) public  {
        require(admin[msg.sender], "Caller is not admin");
        metadataURI = _metadataURI;
    }

    function reveal() public {
        require(admin[msg.sender], "Caller is not admin");
        isRevealed = true;
    }  
    
    function setMintDeposit(address _mintDepositAddress) public 
    {
        require(admin[msg.sender], "Caller is not admin");
        mintDepositAddress = _mintDepositAddress;
    }
}