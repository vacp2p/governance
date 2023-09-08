pragma solidity >=0.5.0 <0.6.0;

contract Proposal {

    enum Vote {Null, Rejection, Approval}

    MiniMeToken token;

    address destination;
    bytes proposalData;
    
    uint256 blockStart;
    uint256 blockEnd;

    bytes32[] public signatures;
    mapping(address => Vote) public voteMap;

    //tabulation process 
    uint256 public lastTabulationBlock;
    mapping(address => address) public tabulated;
    mapping(uint8 => uint256) public results;

    Vote public result;

    modifier votingPeriod {
        require(block.number >= blockStart, "Voting not started");
        require(block.number <= blockEnd, "Voting ended");
        _;
    }

    modifier tabulationPeriod {
        require(block.number > voteBlockEnd, "Voting not ended");
        require(result == Vote.Null, "Tabulation ended");
        _;
    }

    modifier tabulationFinished {
        require(lastTabulationBlock != 0, "Tabulation not started");
        require(lastTabulationBlock + tabulationBlockDelay < block.number, "Tabulation not ended");
        _;
    }

    function vote(uint256 proposalId) external {

    }
    
    function isApproved() public view returns (bool) {
        
    } 


    function finalize() external {
        selfdestruct(msg.sender);
    }

}