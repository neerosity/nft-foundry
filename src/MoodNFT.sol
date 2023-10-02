// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNFT is ERC721 {
    error ERC721Metadata__URI_QueryFor_NonExistentToken();
    error MoodNft__CantFlipMoodIfNotOwner();

    enum Mood {
        HAPPY,
        SAD
    }

    uint256 private s_tokenCounter;
    string private s_sadSvgImageUri;
    string private s_happySvgImageUri;

    mapping(uint256 => Mood) private s_tokenIdToState;

    event CreatedNFT(uint256 indexed tokenId);

    constructor(
        string memory _sadSvgImageUri,
        string memory _happySvgImageUri
    ) ERC721("Mood NFT", "MNT") {
        s_tokenCounter = 0;
        s_sadSvgImageUri = _sadSvgImageUri;
        s_happySvgImageUri = _happySvgImageUri;
    }

    function mintNFT() public {
        uint256 tokenCounter = s_tokenCounter;
        _safeMint(msg.sender, tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
        emit CreatedNFT(tokenCounter);
    }

    function flipMood(uint256 _tokenId) public {
        if (!_isApprovedOrOwner(msg.sender, _tokenId))
            revert MoodNft__CantFlipMoodIfNotOwner();

        if (s_tokenIdToState[_tokenId] == Mood.HAPPY) {
            s_tokenIdToState[_tokenId] = Mood.SAD;
        } else {
            s_tokenIdToState[_tokenId] = Mood.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        string memory imageURI;
        if (s_tokenIdToState[_tokenId] == Mood.HAPPY) {
            imageURI = s_happySvgImageUri;
        } else {
            imageURI = s_sadSvgImageUri;
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(),
                                '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                                '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
