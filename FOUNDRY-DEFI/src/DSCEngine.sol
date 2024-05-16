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
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import { DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import { IERC20 } from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
// import { OracleLib, AggregatorV3Interface } from "./libraries/OracleLib.sol";

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

contract DSCEngine is ReentrancyGuard {
    ///////////////
    // errors ///
    ///////////////
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine_TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine_TokenIsNotAllowed();
    error DSCEngine__TransferFailed();
    error DSCEngine__MintFailed();
    error DSCEngine__BreaksHealthFactor();
    //   error DSCEngine__HealthFactorOk();

    ///////////////
    // state variables ///
    ///////////////
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50;
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;

    mapping(address token => address priceFeed) private s_priceFeed; //tokenToPriceFeed
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 amount) private s_DSCMinted; 
    address[] private s_collateralTokens;
    

    



    DecentralizedStableCoin private immutable i_dsc;

    ///////////////
    // events ///
    ///////////////
    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);
    // event CollateralWithdrawn(address indexed user, address indexed token, uint256 amount);
    // event DscMinted(address indexed user, uint256 amount);
    // event DscRedeemed(address indexed user, uint256 amount);

    ///////////////
    // modifiers ///
    ///////////////
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }

        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeed[token] == address(0)) {
            revert DSCEngine_TokenIsNotAllowed();
        }

        _;
    }

    ///////////////
    // functions ///
    ///////////////
    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        //usd price feeds
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine_TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeed[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }
        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    ///////////////
    // External functions///
    ///////////////

    function depositeCollateralAndMintDsc() external {}

    /*
    * @notice folows CEI
     * @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
     * @param amountCollateral: The amount of collateral you're depositing
     * @param amountDscToMint: The amount of DSC you want to mint
     * @notice This function will deposit your collateral and mint DSC in one transaction
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
      bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }



    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

     /*
     * @param amountDscToMint: The amount of DSC you want to mint
     * You can only mint DSC if you hav enough collateral
     */

  

       function mintDsc(uint256 amountDscToMint) public moreThanZero(amountDscToMint) nonReentrant {
        s_DSCMinted[msg.sender] += amountDscToMint;
        _revertIfHealthFactorIsBroken(msg.sender);
        bool minted = i_dsc.mint(msg.sender, amountDscToMint);

        if (minted != true) {
            revert DSCEngine__MintFailed();
        }
    }

    function burnDsc() external {}

    function liquidate() external {}
  ///////////////
    // private and internal view functions///
    ///////////////

     function _getAccountInformation(address user)
        private
        view
        returns (uint256 totalDscMinted, uint256 collateralValueInUsd)
    {
        totalDscMinted = s_DSCMinted[user];
        collateralValueInUsd = getAccountCollateralValue(user);
    }

    /*
    * returns how close to liquidation a user is
    * if a user goes below 1, then they can get liqudation
    * 
    */

    function _healthFactor(address user) private view returns (uint256) {
     (uint256 totalDiscMinted , uint256 CollateralValueInUsd) = _getAccountInformation(user);
      uint256 collateralAdjustedForThreshold = (CollateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
      return (collateralAdjustedForThreshold * PRECISION) / totalDiscMinted;
    //  return (CollateralValueInUsd / totalDiscMinted)
  }
   
     function _revertIfHealthFactorIsBroken(address user) internal view {
        uint256 userhealthFactor = _healthFactor(user);
        if (userhealthFactor < 1) {
            revert DSCEngine__BreaksHealthFactor(userhealthFactor);
        }

       
     }

        ///////////////
    // public  and external view functions///
    ///////////////



       function getAccountCollateralValue(address user) public view returns (uint256 totalCollateralValueInUsd) {
        for (uint256 index = 0; index < s_collateralTokens.length; index++) {
            address token = s_collateralTokens[index];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += _getUsdValue(token, amount);
        }
        return totalCollateralValueInUsd;
    }

  

      function getUsdValue(
        address token,
        uint256 amount // in WEI
    )
        external
        view
        returns (uint256)
    {
        return getUsdValue(token, amount);
    }
        

        

}
