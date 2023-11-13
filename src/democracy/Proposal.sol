// SPDX-License-Identifier: CC0-1.0
pragma solidity >=0.8.19;

import { MiniMeToken } from "../token/MiniMeToken.sol";

contract Proposal {
    enum Vote {
        Null,
        Rejection,
        Approval
    }

    MiniMeToken public immutable token;

    address public immutable destination;
    bytes public proposalData;

    uint256 public immutable blockStart;
    uint256 public immutable blockEnd;

    bytes32[] public signatures;
    mapping(address voter => Vote vote) public voteMap;

    //tabulation process
    uint256 public lastTabulationBlock;
    mapping(address => address) public tabulated;
    mapping(uint8 => uint256) public results;

    Vote public result;

    modifier votingPeriod() {
        require(block.number >= blockStart, "Voting not started");
        require(block.number <= blockEnd, "Voting ended");
        _;
    }

    modifier tabulationPeriod() {
        require(block.number > blockEnd, "Voting not ended");
        require(result == Vote.Null, "Tabulation ended");
        _;
    }

    modifier tabulationFinished() {
        require(lastTabulationBlock != 0, "Tabulation not started");
        require(lastTabulationBlock + lastTabulationBlock < block.number, "Tabulation not ended");
        _;
    }

    function vote(uint256 proposalId) external { }

    function isApproved() public view returns (bool) { }

    function finalize() external {
        selfdestruct(msg.sender);
    }
}
