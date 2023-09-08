// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;
/*
    Copyright 2016, Jordi Baylina

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
/**
 * @title MiniMeToken Contract
 * @author Jordi Baylina
 * @dev This token contract's goal is to make it easy for anyone to clone this
 *  token using the token distribution at a given block, this will allow DAO's
 *  and DApps to upgrade their features in a decentralized manner without
 *  affecting the original token
 * @dev It is ERC20 compliant, but still needs to under go further testing.
 */

import "./MiniMeTokenCore.sol";

/**
 * @dev The actual token contract, the default controller is the msg.sender
 *  that deploys the contract, so usually this token will be deployed by a
 *  token controller contract, which Giveth will call a "Campaign"
 */
contract MiniMeToken is MiniMeTokenCore {

    constructor(
        address _tokenFactory,
        address payable _parentToken,
        uint _parentSnapShotBlock,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        bool _transfersEnabled
    ) MiniMeTokenCore(_tokenFactory, _parentToken, _parentSnapShotBlock, _tokenName, _decimalUnits, _tokenSymbol, _transfersEnabled) Semver(1, 0, 1) {

    }

////////////////
// Generate and destroy tokens
////////////////
    
    /**
     * @notice Generates `_amount` tokens that are assigned to `_owner`
     * @param _owner The address that will be assigned the new tokens
     * @param _amount The quantity of tokens generated
     * @return True if the tokens are generated correctly
     */
    function generateTokens(
        address _owner,
        uint _amount
    )
        public
        onlyController
        returns (bool)
    {
        _mint(_owner, _amount);
        return true;
    }

    /**
     * @notice Burns `_amount` tokens from `_owner`
     * @param _owner The address that will lose the tokens
     * @param _amount The quantity of tokens to burn
     * @return True if the tokens are burned correctly
     */
    function destroyTokens(
        address _owner,
        uint _amount
    ) 
        public
        onlyController
        returns (bool)
    {
        _burn(_owner, _amount);
        return true;
    }

}
