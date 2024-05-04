//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import {Script} from "forge-std/Script.sol";
// import {Script} from "../lib/forge-std/scripts/vm.py";
import {BasicNft} from "../src/BasicNft.sol";

contract DeployBasicNft is Script {
    function run() external returns (BasicNft) {
        vm.startBroadcast();
        BasicNft basicNft = new BasicNft();
        vm.stopBroadcast();
        return basicNft;
    }
}
