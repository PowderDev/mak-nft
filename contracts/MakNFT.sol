// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract MakNFT is ERC721, Ownable, VRFConsumerBaseV2, ERC721URIStorage {
    enum Rarity {
        Common,
        Rare,
        Legendary
    }

    event NFTRequested(uint indexed requestId, address indexed requester);
    event NFTMinted(uint indexed tokenId, address indexed minter, string uri);

    uint256 private _nextTokenId;

    string public baseURI;
    uint public maxSupply = 100;
    // 1 MSC - Mak StableCoin - 1 USD
    uint public price = 1e18;

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    address public i_mscAddress;
    uint64 private immutable i_subId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callBackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_RANDOM_WORDS = 1;

    mapping(uint256 => address) private requestIdToAddress;

    constructor(
        address vrfCoordinator,
        uint64 subId,
        bytes32 gasLane,
        uint32 callBackGasLimit,
        string memory _baseURI,
        address mscAddress
    ) ERC721("MakNFT", "MNFT") Ownable(msg.sender) VRFConsumerBaseV2(vrfCoordinator) {
        i_subId = subId;
        i_gasLane = gasLane;
        i_callBackGasLimit = callBackGasLimit;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        baseURI = _baseURI;
        i_mscAddress = mscAddress;
    }

    function requestNFT() external returns (uint requestId) {
        require(_nextTokenId < maxSupply, "MakNFT: Max supply reached");
        require(
            IERC20(i_mscAddress).balanceOf(msg.sender) >= price,
            "MakNFT: Insufficient MSC balance"
        );

        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subId,
            REQUEST_CONFIRMATIONS,
            i_callBackGasLimit,
            NUM_RANDOM_WORDS
        );

        requestIdToAddress[requestId] = msg.sender;

        IERC20(i_mscAddress).transferFrom(msg.sender, address(this), price);

        emit NFTRequested(requestId, msg.sender);
        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint randomNumber = (randomWords[0] % 100) + 1;
        uint256 tokenId = _nextTokenId++;

        _safeMint(requestIdToAddress[requestId], tokenId);

        Rarity rarity = getRarity(randomNumber);

        string memory rarityString = Strings.toString(uint256(rarity));
        string memory uri = string(abi.encodePacked(baseURI, "/", rarityString, ".json"));
        _setTokenURI(tokenId, uri);

        emit NFTMinted(tokenId, requestIdToAddress[requestId], uri);
    }

    function getRarity(uint randomNumber) public pure returns (Rarity) {
        if (randomNumber <= 10) return Rarity.Legendary;
        if (randomNumber <= 30) return Rarity.Rare;
        return Rarity.Common;
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function getTotalSupply() public view returns (uint) {
        return _nextTokenId;
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
