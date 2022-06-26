// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFTCollection is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    using Strings for uint256;
    string public baseTokenURI;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    function mint() public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(
            newItemId,
            "https://gateway.pinata.cloud/ipfs/QmbbA1YRjzSpSbUdaqoW1wiQU8MRYTaHK6fZPJCyWJEMpW/"
        );

        return newItemId;
    }

    function setTokenURI(string memory _baseTokenURI) external onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
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

        //string memory baseURI = _baseURI();
        return
            bytes(baseTokenURI).length > 0
                ? string(
                    abi.encodePacked(baseTokenURI, tokenId.toString(), ".json")
                )
                : "";
    }
}
