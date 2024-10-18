// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title An NFT smart contract where the NFT depends on the mood of the owner
 * @author Shuayb Yusuf, 0xshuayb
 */

contract MoodNft is ERC721 {
    // Errors
    error MoodNft__CantFlipMoodIfNotOwner();

    uint256 private s_tokenCounter;
    string private s_happySvgImageUri;
    string private s_sadSvgImageUri;


    enum Mood {
        HAPPY,
        SAD
    }

    mapping(uint256 => Mood) private s_tokenIdToMood;

    constructor(string memory happySvgImageUri, string memory sadSvgImageUri) ERC721("MoodNft", "MN") {
        s_tokenCounter = 0;
        s_happySvgImageUri = happySvgImageUri;
        s_sadSvgImageUri = sadSvgImageUri;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
    }

    function flipMood(uint256 tokenId) public {
        // Only owner can flip mood
        if(getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender) revert MoodNft__CantFlipMoodIfNotOwner();
        if (s_tokenIdToMood[s_tokenCounter] == Mood.HAPPY) {
            s_tokenIdToMood[s_tokenCounter] = Mood.SAD;
            }
        else {
            s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
            }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64, ";
    }

    function tokenURI(uint256 /* tokenId */) public view override returns (string memory) {
        string memory imageURI;

        if (s_tokenIdToMood[s_tokenCounter] == Mood.HAPPY) {
            imageURI = s_happySvgImageUri;
        } else {
            imageURI = s_sadSvgImageUri;
        }
        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{ "name": "',
                            name(),
                            '", "description": "An NFT that reflects the owners mood.", "attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    function getMood() public view returns(Mood) {
        return s_tokenIdToMood[s_tokenCounter];
    }
}