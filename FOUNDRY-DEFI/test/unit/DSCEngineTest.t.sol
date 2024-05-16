// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {DSCEngine} from "../../src/DSCEngine.sol";

import "forge-std/Test.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import { DeployDSC } from "../../script/DeployDSC.s.sol";
// import { ERC20Mock } from "@openzeppelin/contracts/mocks/ERC20Mock.sol"; Updated mock location
import { ERC20Mock } from "../mocks/ERC20Mock.sol";



contract DSCEngineTest is Test {
   
    DSCEngine public dsce;
    DecentralizedStableCoin public dsc;
    HelperConfig public helperConfig;

    address public ethUsdPriceFeed;
    address public btcUsdPriceFeed;
    address public weth;
    address public wbtc;
    uint256 public deployerKey;

    uint256 amountCollateral = 10 ether;
    uint256 amountToMint = 100 ether;
    address public USER  = makeAddr("user");


     uint256 public constant AMOUNT_COLLATERAL = 10 ether;
     uint256 public constant STARTING_USER_BALANCE = 10 ether;
    // uint256 public constant MIN_HEALTH_FACTOR = 1e18;
    // uint256 public constant LIQUIDATION_THRESHOLD = 50;

    // Liquidation
    address public liquidator = makeAddr("liquidator");
    uint256 public collateralToCover = 20 ether;




    function setUp() public {
    dscEngine = new DSCEngine();
    (dsc, dsce) = deployer.run();
    (ethUsdPriceFeed,, weth,,) = config.activeNetworkConfig();
    ERC20Mock(weth).mint(USER, STARTING_USER_BALANCE);

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

  ///////////////// ///////
  // depositcollateral  price Tests ////
  /////////////////////

  function testRevertIfCollateralZero() public {
    vm.startPrank(USER);
    ERC20Mock(weth).approve(address(dsce), 0);
    vm.expectRevert(DSCEngine.DSCEngine_NeedsMoreThanZero.selector);
    dsce.depositCollateral(weth,0);
    vm.stopPrank()

   
  }

  


