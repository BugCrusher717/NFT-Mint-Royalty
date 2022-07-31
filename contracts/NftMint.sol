// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract FirstMintNFT is ERC721, Ownable ,ReentrancyGuard{

    using Strings for string;
    using SafeMath for uint256;

    bool private paused;
    bool private stoped;
    bool private restarted;

    address payable private admin = payable(0xfd046d678588e3a0b714Bf1B1d0d22c8703Fd666);
    uint256 private max_cost = 5 ether;
    uint256 private min_cost = 1.5 ether;
    uint256 private NFT1_cost;
    uint256 private royality = 76;

    uint256 private _num_nft1 = 1111;

    string public baseURI;
    string public baseExtension = ".json";

    uint256 public lastRun;
    uint256 public newRun;

    mapping (address => bool) public buyer;
    

    constructor(
        string memory _initBaseURI
    ) ERC721("NftMint1", "NFT1") {
        setBaseURI(_initBaseURI);
        lastRun = block.timestamp;
    }

    function mintNFT(uint256 id) public payable nonReentrant{
        require(paused == false, "Mint is paused");
        require(stoped == false, "Mint is stoped");
        require(buyer[msg.sender] == false, "Already Minted NFT1");
        newRun = block.timestamp;
        NFT1_cost = max_cost.sub(newRun.sub(lastRun).div(2).mul(0.2 ether));
        uint256 amt = msg.value;
        require(amt >= NFT1_cost, "Not Enough");
        buyer[msg.sender] == true;
        _safeMint(msg.sender, id);
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
        newRun = block.timestamp;
        NFT1_cost = max_cost.sub(newRun.sub(lastRun).div(2).mul(0.2 ether));
    }

    function stop(bool _state) public onlyOwner {
        stoped = _state;
        lastRun = block.timestamp;
    }

    function restart(bool _state) public onlyOwner {
        restarted = _state;
        paused = false;
        max_cost = 5 ether;
        min_cost = 1.5 ether;
        NFT1_cost = 5 ether;
        lastRun = block.timestamp;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, Strings.toString(tokenId), baseExtension)): "";
    }

    function getResult(address _buyer) external view returns (bool){
        return buyer[_buyer];
    }
}
