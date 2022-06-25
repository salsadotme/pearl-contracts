// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/* Pearl Signature Verification

How to Sign and Verify
# Signing
1. Create message to sign
2. Hash the message
3. Sign the hash
*. The signer should have a yamp server set in the sc

# Verify
1. Recreate hash from the original message
2. Recover signer from signature and hash
3. Compare recovered signer to claimed signer
4. Once it's validated return yamp server
*/

contract Pearl is ReentrancyGuard, Ownable, Pausable {
    string public defaultYampServer = ""; //"yamp.yamp.chat"
    mapping(address => string) public yampServers;

    // Events
    event YampServerUpdated(
        address indexed _projectOwner,
        string indexed _yampServer
    );
    event DefaultYampServerUpdated(string indexed _defaultYampServer);

    constructor(string memory _defaultYampServer) {
        defaultYampServer = _defaultYampServer;
    }

    function setDefaultYampServer(string memory _defaultYampServer)
        public
        onlyOwner
    {
        defaultYampServer = _defaultYampServer;
        emit DefaultYampServerUpdated(_defaultYampServer);
    }

    function setYampServer(address _projectOwner, string memory _yampServer)
        public
        onlyOwner
    {
        yampServers[_projectOwner] = _yampServer;
        emit YampServerUpdated(_projectOwner, _yampServer);
    }

    /* 1. Unlock MetaMask account
    ethereum.enable()
    */

    /* 2. Get message hash to sign
    getMessageHash(
        0x111,
        123,
        "Pearl message...",
        1
    )

    hash = "0x123456789"
    */
    function getMessageHash(
        address _to,
        uint _amount,
        string memory _message,
        uint _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }

    /* 3. Sign message hash
    # using browser
    account = "account of signer, i.e. nft project owner"
    ethereum.request({ method: "personal_sign", params: [account, hash]}).then(console.log)

    # using web3
    web3.personal.sign(hash, web3.eth.defaultAccount, console.log)

    Signature will be different for different accounts
    0x999
    */
    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function verifyAndGetYampServer(
        address _signer,
        address _to,
        uint _amount,
        string memory _message,
        uint _nonce,
        bytes memory signature
    ) public view returns (string memory) {
        require(
            verify(_signer, _to, _amount, _message, _nonce, signature),
            "Signer not valid"
        );

        string memory _yampServer = yampServers[_signer];
        return bytes(_yampServer).length > 0 ? _yampServer : defaultYampServer;
    }

    /* 4. Verify signature
    signer = 0x222
    to = 0x111
    amount = 123
    message = "Pearl message..."
    nonce = 1
    signature =
        0x999
    */
    function verify(
        address _signer,
        address _to,
        uint _amount,
        string memory _message,
        uint _nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _amount, _message, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}
