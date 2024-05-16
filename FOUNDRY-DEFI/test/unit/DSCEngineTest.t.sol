// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {DSCEngine} from "../../src/DSCEngine.sol";

import "forge-std/Test.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import { DeployDSC } from "../../script/DeployDSC.s.sol";



contract DSCEngineTest is Test {
   

        DSCEngine public dsce;
    DecentralizedStableCoin public dsc;
    HelperConfig public helperConfig;


    function setUp() public {
    dscEngine = new DSCEngine();
    (dsc, dsce) = deployer.run();
    (ethUsdPriceFeed,, weth,,) = config.activeNetworkConfig();

  }
  ///////////////// 
  // price Tests ////
  //////////////////

    function testGetUsdValue() public {
        uint256 ethAmount = 15e18;
        // 15e18 ETH * $2000/ETH = $30,000e18
        uint256 expectedUsd = 30_000e18;
        uint256 usdValue = dsce.getUsdValue(weth, ethAmount);
        assertEq(usdValue, expectedUsd);
    }
  }


