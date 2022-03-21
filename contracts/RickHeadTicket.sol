// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract RickHeadTicket is ERC721, Ownable {
    using Strings for uint256;

    uint256 public constant totalNbOfTickets = 3333;
    mapping(uint256 => bool) public ticketMinted;
    mapping(address => uint256) public ticketId;
    mapping(address => uint256) public ticketBalance;
    
    string private baseURI = "ipfs://QmdYXZnyeMXLdTQvkKDmtJ9sqfWqcbjyqtratx5JVBcT3K/nft";

    constructor(address[] memory _rickHeadHolders, uint[] memory _rickHeadIds) ERC721("RickHeadTicket", "RHT") {
        for (uint256 i=0; i < _rickHeadHolders.length; i++){
            ticketId[_rickHeadHolders[i]] = _rickHeadIds[i];
            ticketBalance[_rickHeadHolders[i]] += 1;
        }
    }

    function getTicketURI(uint256 _rickHeadId) public view returns (string memory){ 
        require(_exists(_rickHeadId), "ERC721: Query for non-existent token");
        return bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, _rickHeadId.toString()))
        : "";        
    }

    function checkNbOfTickets(address _rickHeadHolder) public view returns(uint256){
        return ticketBalance[_rickHeadHolder];        
    }

    function mintTicket(uint256 _ticketId) public {
        require (ticketId[msg.sender] == _ticketId, "You cannot claim this ticket");
        require ();  //set counter for number of tickets minted

    }

}