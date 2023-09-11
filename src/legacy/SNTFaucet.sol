// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "./SNTPlaceHolder.sol";

contract SNTFaucet is SNTPlaceHolder {
    bool public open = true;

    constructor(address _owner, address payable _snt) SNTPlaceHolder(_owner, _snt) { }

    fallback() external {
        generateTokens(msg.sender, 1000 * (10 ** uint256(snt.decimals())));
    }

    function mint(uint256 _amount) external {
        require(open);
        generateTokens(msg.sender, _amount);
    }

    function setOpen(bool _open) external onlyOwner {
        open = _open;
    }

    function destroyTokens(address _who, uint256 _amount) public onlyOwner {
        snt.destroyTokens(_who, _amount);
    }

    function generateTokens(address _who, uint256 _amount) public {
        require(msg.sender == owner || open);
        snt.generateTokens(_who, _amount);
    }
}
