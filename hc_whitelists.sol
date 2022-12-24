// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract HCProjectWhitelists is Ownable{
    struct Whitelists{
        bool whitelist1;
        bool whitelist2;        
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

    mapping (address=> Whitelists) public whitelists;
    mapping (address => bool) public admin;

    constructor()  
    {        
        admin[owner()] = true;               
    }  
    function setAdmin(address _address) public onlyOwner{
        admin[_address] = true;
    } 

    function addToWhitelist(Phase phase, address[] calldata toAddAddresses) public
    {
        require(admin[msg.sender], "Caller is not admin");
        if(phase == Phase.Whitelist1)
        {
            for (uint i = 0; i < toAddAddresses.length; i++)
            {
                whitelists[toAddAddresses[i]].whitelist1 = true;
            }                 
        }
        else if(phase == Phase.Whitelist2)
        {
            for (uint i = 0; i < toAddAddresses.length; i++)
            {
                whitelists[toAddAddresses[i]].whitelist2 = true;
            }            
        }        
    }

    function setWhitelist(Phase phase, address _whitelistAddress) public {        
        require(admin[msg.sender], "Caller is not admin");
        if(phase == Phase.Whitelist1)
        {
            whitelists[_whitelistAddress].whitelist1 = true;            
        }
        else if(phase == Phase.Whitelist2)
        {
            whitelists[_whitelistAddress].whitelist2 = true;            
        }
        
    }

    function deleteWhitelist(Phase phase, address _whitelistAddress) public {        
        require(admin[msg.sender], "Caller is not admin");
        if(phase == Phase.Whitelist1)
        {
            whitelists[_whitelistAddress].whitelist1 = false;            
        }
        else if(phase == Phase.Whitelist2)
        {
            whitelists[_whitelistAddress].whitelist2 = false;            
        }
             
    }

}