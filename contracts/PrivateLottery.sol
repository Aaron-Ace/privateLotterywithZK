// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

// Plonk verifier function (proof, public signals)
interface IPlonkVerifier {
    function verifyProof(bytes memory proof, uint[] memory pubSignals) external view returns (bool);
}

// ERC-20 transfer function (recipient, amount)
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

// Lottery contract with merkle-tree inclusion proofs
contract PrivateLottery is Ownable {
    // State variables
    IERC20 public airdrop_erc;
    uint public amount;
    IERC721NFT public airdrop;
    IPlonkVerifier verifier;
    bytes32 public root;
    uint256[] commitments;
    uint256[] eligibleSet;
    uint256[] public _randomNumbers;
    uint256 public nextTokenIdToBeAirdropped;

    // Map each address to nullifier -- i.e. whether user already collected airdrop
    mapping(bytes32 => bool) public nullifierSpent;

    // Map to check whether user is in eligibileSet
    mapping(uint256 => bool) public Eligible;

    // SNARK field 
    uint256 constant SNARK_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;


    function deposit(bytes32 _commitment) external payable nonReentrant {
        require(!commitments[_commitment], "The commitment has been submitted");

        uint32 insertedIndex = _insert(_commitment);
        commitments[_commitment] = true;
        _processDeposit();

        emit Deposit(_commitment, insertedIndex, block.timestamp);
    }



    // Verify proof, updated nullifier set, collect airdrop
    function collectAirdrop(uint256 commitment, bytes calldata proof, bytes32 nullifierHash) public {
        // Make sure commitment is in the eligibility set
        require(getEligible(commitment), "Commitment is not in the eligibility set!");

        // Check against nullifier set (i.e. nullifier hash to false)
        require(uint256(nullifierHash) < SNARK_FIELD ,"Nullifier is not within the field!");
        require(!nullifierSpent[nullifierHash], "Airdrop already redeemed!");

        // Plonk verifier to verify proof
        uint[] memory pubSignals = new uint[](3);
        pubSignals[0] = uint256(root);
        pubSignals[1] = uint256(nullifierHash);
        pubSignals[2] = uint256(uint160(msg.sender));
        // add another public signal for commitment chosen
        require(verifier.verifyProof(proof, pubSignals), "Proof verification failed!");

        // Set nullifier hash to true
        nullifierSpent[nullifierHash] = true;

         // Transfer and collect erc-20 airdrop
        airdrop_erc.transfer(msg.sender, amount);

        // // Transfer and collect nft airdrop
        // airdrop.transferFrom(address(this), msg.sender, nextTokenIdToBeAirdropped);
        // nextTokenIdToBeAirdropped++;
    }
}
