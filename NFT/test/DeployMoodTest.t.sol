//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployMoodNft} from "../script/DeployMoodNft.s.sol";

contract DeployMoodTest is Test {
    DeployMoodNft public deployer;
    function setUp() public {
        deployer = new DeployMoodNft()

    }
    function testConvertSvgToUri() public {
        string memory expectedUri = "" ,
        string memory svg = "",
        string memory actualUri = deployer.svgToImageURI(svg);
        assert (keccak256(abi.encodePacked(actualUri)) == keccak256(abi.encodePacked(expectedUri)));

    }
}