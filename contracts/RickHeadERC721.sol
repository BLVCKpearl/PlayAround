// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RickHeadERC721 is ERC721, Pausable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenId;

    uint256 public constant maxSupply = 3333;
    uint256 private constant maxMintsPerAddress = 4;
    uint256 private constant maxPrivateMintsPerAddress = 2;
    uint256 private constant maxPresaleMintsPerAddress = 1;
    uint256 public mintPrice = 0.15 ether;

    string private baseURI = "ipfs://QmdYXZnyeMXLdTQvkKDmtJ9sqfWqcbjyqtratx5JVBcT3K/nft";

    bool public collectionRevealed = false;

    enum SalePhase {
        Locked,
        Private,
        Presale,
        Public
    }
    enum CouponType {
        Private,
        Presale
    }

    struct Coupon {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    address private _adminSigner = 0x0000000000000000000000000000000000000000;

    SalePhase public phase = SalePhase.Locked;

    constructor() ERC721("MyToken", "MTK") {}

    function circulatingSupply() public view returns (uint256) {
        return _tokenId.current();
    }

    function setPhase(uint256 phasePrice_, SalePhase phase_)
        external
        onlyOwner
    {
        // require(uint8(phase_) > uint8(phase), "can only advance phases");
        phase = phase_;
        mintPrice = phasePrice_;
    }

    /**
     * emits a {Transfer} event for each token ID minted by the contract
     * the Transfer event is declared in the IERC721 interface
     */

    function mint(uint256 amount, Coupon memory coupon)
        external
        payable
        whenNotPaused
    {
        uint256 currentSupply = _tokenId.current();
        require(phase != SalePhase.Locked, "No sale phase is open");
        if (phase == SalePhase.Private) {
            bytes32 digest = keccak256(
                abi.encode(CouponType.Private, msg.sender)
            );
            require(_isVerifiedCoupon(digest, coupon), "Invalid coupon");
            require(
                amount < maxPrivateMintsPerAddress,
                "you can only mint 2 NFTs during Private sale"
            );
        } else if (phase == SalePhase.Presale) {
            bytes32 digest = keccak256(
                abi.encode(CouponType.Presale, msg.sender)
            );
            require(_isVerifiedCoupon(digest, coupon), "Invalid coupon");
            require(
                amount < maxPresaleMintsPerAddress,
                "you can only mint 2 NFTs during Presale"
            );
        }
        require(
            currentSupply + amount <= maxSupply,
            "Max supply limit reached, please reduce mint amount"
        );
        require(
            balanceOf(msg.sender) + amount <= maxMintsPerAddress,
            "Max mint per address reached, reduce amount to mint"
        );
        require(msg.value >= amount * mintPrice, "Insufficient funds");
        for (uint256 i = 0; i < amount; i++) {
            _tokenId.increment();
            _safeMint(msg.sender, _tokenId.current());
        }
    }

    function _isVerifiedCoupon(bytes32 digest, Coupon memory coupon)
        internal
        view
        returns (bool)
    {
        // address signer = digest.recover(signature);
        address signer = ecrecover(digest, coupon.v, coupon.r, coupon.s);
        require(signer != address(0), "ECDSA: invalid signature"); // Added check for zero address
        return signer == _adminSigner;
    }

    function setAdminSigner(address _newAdminSigner) public onlyOwner() returns (address) {
        _adminSigner = _newAdminSigner;
        return _adminSigner;
    }

    function getAdminSigner() public view returns(address){
        return _adminSigner;
    }

    function revealCollection(string memory _revealURI)
        external
        onlyOwner
        returns (string memory)
    {
        // require(collectionRevealed == true, "collection has not been revealed");
        collectionRevealed = true;
        baseURI = _revealURI;
        return baseURI;
    }

    function getURI() public view returns(string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId), "ERC721: Query for non-existent token");
        if (collectionRevealed == false) {
            return baseURI;
        } else {
            return
                bytes(baseURI).length > 0
                    ? string(abi.encodePacked(baseURI, tokenId.toString()))
                    : "";
        }
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }
}
