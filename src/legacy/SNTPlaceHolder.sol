// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;
import "./token/TokenController.sol";
import "./token/MiniMeToken.sol";
import "./SafeMath.sol";
import "./Owned.sol";

/*
    Copyright 2017, Jordi Baylina

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

/// @title SNTPlaceholder Contract
/// @author Jordi Baylina
/// @dev The SNTPlaceholder contract will take control over the SNT after the contribution
///  is finalized and before the Status Network is deployed.
///  The contract allows for SNT transfers and transferFrom and implements the
///  logic for transferring control of the token to the network when the offering
///  asks it to do so.
contract SNTPlaceHolder is TokenController, Owned {
    using SafeMath for uint256;
    MiniMeToken public snt;

    constructor(address _owner, address payable _snt) {
        owner = _owner;
        snt = MiniMeToken(_snt);
    }

    /// @notice The owner of this contract can change the controller of the SNT token
    ///  Please, be sure that the owner is a trusted agent or 0x0 address.
    /// @param _newController The address of the new controller
    function changeController(address _newController) public onlyOwner {
        snt.changeController(_newController);
        emit ControllerChanged(_newController);
    }
 
    //////////
    // MiniMe Controller Interface functions
    //////////

    // In between the offering and the network. Default settings for allowing token transfers.
    function proxyPayment(address) override public payable returns (bool) {
        return false;
    }

    function onTransfer(address, address, uint256) override  public pure returns (bool) {
        return true;
    }

    function onApprove(address, address, uint256) override public pure returns (bool) {
        return true;
    }
    
    event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
    event ControllerChanged(address indexed _newController);
}