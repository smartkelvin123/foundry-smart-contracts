// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity 0.8.20;

// import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

/*
 * @title DSCEngine
 * @author smart kelvin
 *
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg at all times.
 * This is a stablecoin with the properties:
 * - Exogenously Collateralized
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was backed by only WETH and WBTC.
 *
 * Our DSC system should always be "overcollateralized". At no point, should the value of
 * all collateral < the $ backed value of all the DSC.
 *
 * @notice This contract is the core of the Decentralized Stablecoin system. It handles all the logic
 * for minting and redeeming DSC, as well as depositing and withdrawing collateral.
 * @notice This contract is based on the MakerDAO DSS system
 */

contract DSCEngine  is ReentrancyGuard {
      ///////////////
        // errors /// 
        /////////////// 
  error DSCEngine__NeedsMoreThanZero();
  error DSCEngine_TokenAddressesAndPriceFeedAddressesMustBeSameLength();

       ///////////////
        // state variables /// 
        /////////////// 
    mapping (address token => address priceFeed) private s_priceFeed;   //tokenToPriceFeed




        ///////////////
        // modifiers /// 
        /////////////// 
    modifier  moreThanZero (uint256 amount){
        if (amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }

        _;
    }

    // modifier isAllowedToken (address token) {}




         ///////////////
        // functions /// 
        /////////////// 
     constructor( 
        address[] memory tokenAddresses,
        address[] memory priceFeedAddresses,
        address dscAddress
     ){
        //usd price feeds
        if (tokenAddresses.length != priceFeedAddresses.length ){
            revert DSCEngine_TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++){
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        //set the DSC token address
        s_dscAddress = dscAddress;
     }

       ///////////////
        // External functions/// 
        /////////////// 

    function depositeCollateralAndMintDsc() external {}


    /*
     * @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
     * @param amountCollateral: The amount of collateral you're depositing
     * @param amountDscToMint: The amount of DSC you want to mint
     * @notice This function will deposit your collateral and mint DSC in one transaction
     */
    function depositCollateral(
        address tokenCollateralAddress, 
        uint256 amountCollateral
    )external  moreThanZero (moreThanZero){

    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function mintDsc() external {
        
    }

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() 



}
