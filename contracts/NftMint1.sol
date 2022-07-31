// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import './NftMint.sol';

interface GetBool {
   function getResult(address _buyer) external view returns (bool);
}

contract SecondMintNFT is ERC721, Ownable ,ReentrancyGuard{

    using Strings for string;
    using SafeMath for uint256;

    address public nftContract;

    bool private paused;
    bool private stoped;
    bool private restarted;


    address payable private admin = payable(0xfd046d678588e3a0b714Bf1B1d0d22c8703Fd666);

    uint256 public nftId;
    uint256 public newRun;
    uint256 public nonce;
    uint256 private royality =  55;
    uint256 private cost = 0.2 ether;
    uint256 private _num_nft = 1111;

    string public baseURI;
    string public baseExtension = ".json";

    mapping (address => bool) public buyer;
    

    constructor(
        string memory _initBaseURI,
        address _nftContract
    ) ERC721("NftMint2", "NFT2") {
        setBaseURI(_initBaseURI);
        nftContract = _nftContract;
    }

    function mintNFT(address _To) public payable nonReentrant{
        require( GetBool(nftContract).getResult(msg.sender) == true, "Not Available");
        require( paused == false, 'Minting is paused');
        require( stoped == false, 'Minting is stoped');
        newRun = block.timestamp;
        uint randomnumber = uint(keccak256(abi.encodePacked(newRun, msg.sender, nonce))) % 1111;
        randomnumber = randomnumber + 1;
        nonce++;
        nftId = randomnumber; 
        uint256 amt = msg.value;
        require(amt >= cost, "Not Enough");
        nftId++;
        _safeMint(_To, nftId);
        admin.transfer(amt);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI (string memory _newBaseURI) public onlyOwner {
        baseURI =  _newBaseURI;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function stop(bool _state) public onlyOwner {
        stoped = _state;
    }

    function restart(bool _state) public onlyOwner {
        restarted = _state;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, Strings.toString(tokenId), baseExtension)): "";
    }
}
