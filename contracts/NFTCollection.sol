// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFTCollection is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Pearl", "PRL") {}

    modifier callerIsUser() {
        require(
            tx.origin == msg.sender,
            "NFTCollection :: Cannot be called by a contract"
        );
        _;
    }

    function _baseURI() internal pure override returns (string memory) {
        return
            "https://gateway.pinata.cloud/ipfs/QmbbA1YRjzSpSbUdaqoW1wiQU8MRYTaHK6fZPJCyWJEMpW/";
    }

    function safeMint() public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function mint(uint256 _quantity) external payable callerIsUser {
        // require(_quantity <= 3, "NFTCollection :: Below 3");
        _safeMint(msg.sender, _quantity);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "NFTCollection: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }
}
