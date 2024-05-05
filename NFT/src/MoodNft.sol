//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is Erc721 {
    error MoodNft__CantFlipMoodIfNotOwner();

    uint256 private s_tokenCounter;
   string private s_sadSvgUri;
    string private s_happySvgUri;
    constructor(string memory sadSvg, string memory happySvg) 
        Erc721("Mood NFT" , "MN"){
        s_tokenCounter = 0 ;
        s_sadSvg = sadSvgUri;
        s_happySvg = happySvgUri

    }

    function mintNft() public {
      _safeMint(msg.sender, s_tokenCounter);
      s_tokenCounter++
    }
 function flipMood(uint256 tokenId) public {
        if (getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender) {
            revert MoodNft__CantFlipMoodIfNotOwner();
        }

        if (s_tokenIdToState[tokenId] == State.HAPPY) {
            s_tokenIdToState[tokenId] = State.SAD;
        } else {
            s_tokenIdToState[tokenId] = State.HAPPY;
        }
    }

     function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert ERC721Metadata__URI_QueryFor_NonExistentToken();
        }
        string memory imageURI = s_happySvgUri;

        if (s_tokenIdToState[tokenId] == NFTState.SAD) {
            imageURI = s_sadSvgUri;
        }
        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes( // bytes casting actually unnecessary as 'abi.encodePacked()' returns a bytes
                        abi.encodePacked(
                            '{"name":"',
                            name(), // You can add whatever name here
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