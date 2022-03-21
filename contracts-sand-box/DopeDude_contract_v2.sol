// SPDX-License-Identifier: MIT

pragma solidity ^ 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract BoredStakers is ERC721, Ownable, Pausable{
    using Strings for uint256; //strings library already inherited in ERC721.sol contract
        using Counters for Counters.Counter;

            //configs
            Counters.Counter internal tokenIds;
    uint256 public constant Max_Supply = 5000;
    uint256 public constant privatesale_price = 0.15 ether;
    uint256 public constant regular_price = 0.2 ether;
    uint256 public Max_Mint_Per_User;
        
    bool public Private_SaleOpen = false;
    bool public Presale_SaleOpen = false;
    bool public Public_SaleOpen = false;
    bool public collectionRevealed = false;

    string private NotRevealedURI = 'https://notrevealedURI/';
    string private RevealedURI = 'https://revealedURI/';

    mapping(address => bool) private Private_Whitelist;
    mapping(address => bool) private Presale_Whitelist;
    


    constructor(uint256 _MaxMintPerUser) ERC721("BoredStakers", "BS"){
        Max_Mint_Per_User = _MaxMintPerUser;
    }


    function Circulating_Supply() public view returns(uint){
        return tokenIds.current();
    }

    // WHITELIST ACTIONS
    function addToPrivateWhiteList(address _user) public onlyOwner(){
        require(Private_Whitelist[_user] == false, "User already whitelisted");
        Private_Whitelist[_user] = true;
    }

    function addToPresaleWhiteList(address _user) public onlyOwner(){
        require(Presale_Whitelist[_user] == false, "User already whitelisted");
        Presale_Whitelist[_user] = true;
    }
    // @dev removes a user from a whitelist
    function removeFromWhiteList(address _user) public onlyOwner() {
        require(Private_Whitelist[_user] == true || Presale_Whitelist[_user] == true, "User is not whitelisted");
        Private_Whitelist[_user] = false;
        Presale_Whitelist[_user] = false;
    }

    // @dev checks if an address is whitelisted
    function PrivateWhitelistedUser(address _user) public view returns(bool){
        return Private_Whitelist[_user];
    }

    function PresaleWhitelistedUser(address _user) public view returns(bool){
        return Presale_Whitelist[_user];
    }

    // Start sales
    function StartPrivateSale() public onlyOwner() {
        Private_SaleOpen = !Private_SaleOpen;

    }
    function StartPreSale() public onlyOwner() {
        Presale_SaleOpen = !Presale_SaleOpen;

    }
    function StartPublicSale() public onlyOwner() {
        Public_SaleOpen = !Public_SaleOpen;
    }


    // @dev pauses and unpauses the contract

    function pauseContract() public onlyOwner(){

    }

    //MINT FUNCTION 

    function Mint(uint256 _amount) public payable whenNotPaused(){
        uint256 circulatingSupply = tokenIds.current();
        require(circulatingSupply <= Max_Supply, "Max supply reached");
        require(circulatingSupply + _amount <= Max_Supply, "you can't mint more than Max supply");
        require(balanceOf(msg.sender) + _amount <= Max_Mint_Per_User, "you've exceeded max mint per wallet");

        if (Private_SaleOpen == true) {
            require(Presale_SaleOpen == false && Public_SaleOpen == false);
            require(Private_Whitelist[msg.sender] == true, "You're not in the private sale whitelist");
            require(msg.value >= privatesale_price * _amount, "Insufficient funds");
        }
        else if (Presale_SaleOpen == true) {
            require(Presale_Whitelist[msg.sender] == true);
            require(Private_SaleOpen == false && Public_SaleOpen == false);
            require(msg.value >= regular_price * _amount, "Insufficient funds");
        }
        else {
            require(Public_SaleOpen == true, "Sale not open");
            require(msg.value >= regular_price * _amount, "Insufficient funds");
        }

        for (uint i = 0; i < _amount; i++) {
            tokenIds.increment();
            _safeMint(msg.sender, tokenIds.current());
        }

    }

    // TOKEN URI
    function tokenURI(uint256 _tokenId) public view virtual override  whenNotPaused() returns(string memory) {
        require(_exists(_tokenId), "Error: token does not exist");
        if (collectionRevealed == true) {
            return bytes(RevealedURI).length > 0
                ? string(abi.encodePacked(RevealedURI, _tokenId.toString(), ".json"))
                : "";
        } else {
            return bytes(NotRevealedURI).length > 0
                ? string(abi.encodePacked(NotRevealedURI, _tokenId.toString(), ".json"))
                : "";
        }
    }

    function revealCollection() public onlyOwner()  whenNotPaused() returns(bool){
        collectionRevealed = true;
        return true;
    }

    function approve(address to, uint256 tokenId) public virtual override whenNotPaused(){
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }


}