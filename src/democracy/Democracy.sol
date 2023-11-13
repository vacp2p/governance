// SPDX-License-Identifier: CC0-1.0
pragma solidity >=0.8.19;

import { Proposal } from "./Proposal.sol";
import { MiniMeToken } from "@vacp2p/minime/contracts/MiniMeToken.sol";

/**
 * @author Ricardo Guilherme Schmidt (Status Research & Development GmbH)
 */
contract Democracy {
    MiniMeToken public token;

    mapping(bytes32 id => Topic t) public topics;

    struct CallId {
        bool delegated;
        address destination;
        bytes4 sig;
    }

    struct Topic {
        ProposalFactory proposalFactory;
        mapping(address => mapping(bytes4 => Allowance)) allowance;
    }

    struct Call {
        Allowance allowance;
        address destination;
        bytes data;
    }

    enum Allowance {
        Null,
        Call,
        DelegateCall
    }

    mapping(Proposal p => Call c) public openProposals;

    enum Vote {
        Abstention,
        Rejection,
        Approval
    }

    modifier self() {
        require(msg.sender == address(this), "Unauthorized");
        _;
    }

    modifier anyone() {
        require(msg.sender != address(this), "Unauthorized");
        _;
    }

    function addTopic(bytes32 topicId, ProposalFactory proposalFactory, CallId[] allowedCalls) external self {
        topics[topicId].proposalFactory = proposalFactory;
        topics[topicId].allowedCalls = allowedCalls;
        for (uint256 i = 0; i < allowedCalls.length; i++) {
            Call allowedCall = allowedCalls[i];
            topics[topicId].allowance[allowedCall.destination][allowedCall.sig] = allowedCall.allowance;
        }
    }

    function setAllowance(bytes32 topicId, CallId[] allowedCalls) external self {
        topics[topicId].allowedCalls = allowedCalls;
    }

    function withdraw(address destination, uint256 value) external self {
        destination.send(value);
    }

    function createProposal(bytes32 topicId, Call call) external anyone {
        require(isTopicAllowed(topicId, call), "Topic not allowed");
    }

    function executeProposal(Proposal proposal) external anyone {
        require(proposal.isApproved(), "Not approved");

        Call call = openProposals[proposal];

        if (call.delegated) {
            call.destination.delegatecall(call.data);
        } else {
            call.destination.call(call.data);
        }

        proposal.finalize();
        if (address(proposal).codehash == bytes32(0)) {
            delete openProposals[proposal];
        }
    }

    function getCallId(Call call) public pure returns (bytes32 callId) {
        bytes4 sig;
        assembly {
            sig := mload(add(call.data, 4))
        }
        callId = getCallId(call.delegated, call.destination, sig);
    }

    function getCallId(bool delegated, address destination, bytes data) public pure returns (bytes32 callId) {
        bytes4 sig;
        assembly {
            sig := mload(add(data, 4))
        }
        callId = getCallId(delegated, destination, sig);
    }

    function getCallId(bool delegated, address destination, bytes4 sig) public pure returns (bytes32 callId) {
        callId = keccak256(delegated, destination, sig);
    }

    function isTopicAllowed(bytes32 topic, Call call) public view returns (bool) {
        if (topic == bytes32(0)) {
            return true; //root topic can always everything
        }

        bytes4 calledSig;
        assembly {
            calledSig := mload(add(call.data, 4))
        }

        return topics[topic].allowance[destination][bytes4(0)] == call.allowance
            || topics[topic].allowance[destination][calledSig] == call.allowance
            || topics[topic].allowance[address(0)][bytes4(0)] == call.allowance
            || topics[topic].allowance[address(0)][calledSig] == call.allowance;
    }
}

contract ProposalFactory {
    function createProposal() external returns (Proposal p) {
        return new Proposal();
    }
}
