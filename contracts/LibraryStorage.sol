// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./SSTORE2.sol";
import '@openzeppelin/contracts/access/Ownable.sol';

contract LibraryStorage is Ownable {
    address immutable operator;

    mapping(uint256 => address[]) _dataLibraries;

    constructor() {
        operator = msg.sender;
    }

    modifier onlyOwnerOrOperator() {
        require(msg.sender == owner() || msg.sender == operator); 
        _;
    }

    function addChunk(uint256 tokenId, string calldata chunk) public onlyOwnerOrOperator {
        _dataLibraries[tokenId].push(SSTORE2.write(bytes(chunk)));
    }

    function getBlockSData(uint256 tokenId) public view returns (string memory o_code) {
        address[] memory chunks = _dataLibraries[tokenId];

        unchecked {
            assembly {
                let len := mload(chunks)
                let totalSize := 0x20
                let size
                o_code := mload(0x40)

                // loop through all chunk addresses
                // - get address
                // - get data size
                // - get code and add to o_code
                // - update total size
                let targetChunk
                for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                    targetChunk := mload(add(chunks, add(0x20, mul(i, 0x20))))
                    size := sub(extcodesize(targetChunk), 1)
                    extcodecopy(targetChunk, add(o_code, totalSize), 1, size)
                    totalSize := add(totalSize, size)
                }

                // update o_code size
                mstore(o_code, sub(totalSize, 0x20))
                // store o_code
                mstore(0x40, add(o_code, and(add(totalSize, 0x1f), not(0x1f))))
            }
        }
    }
}