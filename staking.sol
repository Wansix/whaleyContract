// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NftStaker is Ownable{
    IERC721 public parentNFT;

    struct StakeTokens {
        uint256 token1;        
        uint256 token2;
        uint256 token3;  
        uint256 stakedAddressesIndex;
    }        

    mapping(address => StakeTokens) public stakeTokens;
    mapping(address => bool) public stakeFlags;
    mapping(address => bool) public waitUnstakeFlags;
    mapping(address => bool) public unstakingPossible;
    address [] public stakedAddresses;    
    address [] public waitUnstakeAddresses;
    uint256 public totalStakedNum = 0;
    mapping (address => bool) public admin;
    uint256 public waitUnstakeNum = 0;
    
    constructor(address _address) {
        parentNFT = IERC721(_address); // Change it to your NFT contract addr
        admin[owner()] = true;    
    }

    function setAdmin(address _address) public onlyOwner{
        admin[_address] = true;
    } 

    function transferTokenAdmin(address _address,uint256 _tokenId) public onlyOwner {
        parentNFT.transferFrom(address(this),_address,_tokenId); 

    }

    function stake (uint256 _token1, uint256 _token2, uint256 _token3) public
    {
        require(stakeFlags[msg.sender] == false, "Already staked!");        

        require(parentNFT.ownerOf(_token1) == msg.sender, "It's not owner(token1)");
        require(parentNFT.ownerOf(_token2) == msg.sender, "It's not owner(token2)");
        require(parentNFT.ownerOf(_token3) == msg.sender, "It's not owner(token3)");
        
        parentNFT.safeTransferFrom(msg.sender, address(this), _token1);
        parentNFT.safeTransferFrom(msg.sender, address(this), _token2);
        parentNFT.safeTransferFrom(msg.sender, address(this), _token3);

        stakeFlags[msg.sender] = true;
        stakeTokens[msg.sender].token1 = _token1;
        stakeTokens[msg.sender].token2 = _token2;
        stakeTokens[msg.sender].token3 = _token3;    

        stakeTokens[msg.sender].stakedAddressesIndex = totalStakedNum;        
        stakedAddresses.push(msg.sender);   
        totalStakedNum++; 
    }

    function unstakeRquest() public
    {
        require(stakeFlags[msg.sender] == true, "No Staked.");
        require(waitUnstakeFlags[msg.sender] == false, "Already requested!");        
        
        waitUnstakeAddresses.push(msg.sender);
        waitUnstakeFlags[msg.sender] = true;
        waitUnstakeNum++;
    }

    

    function releaseUnstake() public
    {
        require(admin[msg.sender], "Caller is not admin");
        require(totalStakedNum > 0, "No Staking tokens");

        for(uint i = 0; i < waitUnstakeAddresses.length; i++)
        {
            address unstakeAddress = waitUnstakeAddresses[i];            

            unstakingPossible[unstakeAddress] = true;
           
            // 초기화                        
            waitUnstakeFlags[unstakeAddress] = false;
           
        }       
       
        waitUnstakeNum = 0;
        delete waitUnstakeAddresses;        
    }

    function unstake() public {
        require(unstakingPossible[msg.sender] == true, "can not unstake!");

        parentNFT.safeTransferFrom(address(this), msg.sender, stakeTokens[msg.sender].token1, "0x00");    
        parentNFT.safeTransferFrom(address(this), msg.sender, stakeTokens[msg.sender].token2, "0x00");
        parentNFT.safeTransferFrom(address(this), msg.sender, stakeTokens[msg.sender].token3, "0x00");

        uint256 index = stakeTokens[msg.sender].stakedAddressesIndex;

        //remove stakedAddress
        stakedAddresses[index] = stakedAddresses[stakedAddresses.length - 1];
        stakedAddresses.pop();
        totalStakedNum--;     

        stakeFlags[msg.sender] = false;
        unstakingPossible[msg.sender] = false;        
        delete stakeTokens[msg.sender];
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,        
        bytes calldata data
    ) external returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

}