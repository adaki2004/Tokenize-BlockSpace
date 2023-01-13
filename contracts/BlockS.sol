// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import './Base64.sol';
import './LogoBase64.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

interface ILibraryStorage {
    function getBlockSData(
        uint256 _tokenId
    ) external view returns (string memory);
}

contract BlockS is ERC721 , Ownable, LogoBase64 {
    address immutable operator;
    address immutable _libStorageAddress;

    // Image to base64 (linux/mac util available)
    // https://onlinejpgtools.com/convert-jpg-to-base64
    string constant templateImageJPG = "data:image/jpg;base64,";
    string constant templateImagePNG = "data:image/png;base64,";
    string constant templatePDF = "data:image/png;base64,";
    string constant templateDOC = "data:image/png;base64,";
    string constant templateZIP = "data:image/png;base64,";

    using Strings for uint256;
    uint256 _nextId = 1;

    enum eType {
        jpg,
        png,
        pdf,
        docx,
        gzip
    }

    /// @dev This is the expanded data for _userQuests
    struct AssetDataStruct {
        eType assetType;
        string assetName;
        string assetDesc;
        string traitTypeValue;
        string traitEncryptionValue;
    }
    mapping(uint256 => AssetDataStruct) _assetData;

    constructor(address libStorageAddress) ERC721 ('Dani BlockSpace', 'DBS') {
        _libStorageAddress = libStorageAddress;
        operator = msg.sender;
    }

    modifier onlyOwnerOrOperator() {
        require(msg.sender == owner() || msg.sender == operator); 
        _;
    }

    function mint(
        uint8 mimeType,
        string memory name,
        string memory desc,
        string memory traitTypeValue,
        string memory traitEncryptionValue
    )
        public onlyOwnerOrOperator {
        _mint(msg.sender, _nextId);
        _assetData[_nextId] = AssetDataStruct(eType(mimeType), name, desc, traitTypeValue, traitEncryptionValue);
        unchecked{
            ++ _nextId;
        }
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {

        AssetDataStruct memory tokenData = _assetData[tokenId];

        string memory dataURI = string.concat(
            '{',
                '"name": "', tokenData.assetName,
                '","description":"', tokenData.assetDesc,
                '","image": "', _getImage(tokenId),
                '","attributes": ', _tokenIdToMetadata(tokenId),
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(bytes(dataURI))
            )
        );
    }

    function _getImage(uint tokenId) internal view returns (string memory) {
        ILibraryStorage libraryStorage = ILibraryStorage(_libStorageAddress);
        string memory mimeType;
        string memory image;
        AssetDataStruct memory tokenData = _assetData[tokenId];

        // If indeed images -> We need the file, otherwise just the logo
        // The actual query for getting the data is getRawData()
        if(tokenData.assetType == eType.jpg) {
            mimeType = templateImageJPG;
            image = libraryStorage.getBlockSData(tokenId);
        }
        else if(tokenData.assetType == eType.png) {
            mimeType = templateImagePNG;
            image = libraryStorage.getBlockSData(tokenId);
        }
        else if(tokenData.assetType == eType.pdf) {
            mimeType = templatePDF;
            image = pdf_svg_xml_base64;
        }
        else if(tokenData.assetType == eType.docx) {
            mimeType = templateDOC;
            image = doc_svg_xml_base64;
        }
        else if(tokenData.assetType == eType.gzip) {
            mimeType = templateZIP;
            image = zip_svg_xml_base64;
        }

        return string.concat(
            mimeType,
            image
        );
    }

    // Function to retrieve the type and the encoded file content/data
    function getRawTypeAndData(uint tokenId) internal view returns (uint8, string memory) {
        ILibraryStorage libraryStorage = ILibraryStorage(_libStorageAddress);

        return (
            uint8(_assetData[tokenId].assetType),
            libraryStorage.getBlockSData(tokenId)
        );
    }

    function _tokenIdToMetadata(uint256 tokenId) internal view returns (string memory) {

        string memory metadataString;
        AssetDataStruct memory tokenData = _assetData[tokenId];

        string memory traitName;
        string memory traitValue;

        for (uint256 index = 0; index < 2; index++) {
            if(index == 0) {
                traitName = "Type";
                traitValue = tokenData.traitTypeValue;
            }
            else {
                traitName = "Encryption";
                traitValue = tokenData.traitEncryptionValue;
            }

            string memory startline;
            if(index!=0) startline = ",";

            metadataString = string(
            abi.encodePacked(
                metadataString,
                startline,
                '{"trait_type":"',
                traitName,
                '","value":"',
                traitValue,
                '"}'
        ));
        }
        
        return string.concat("[", metadataString, "]");

    }
}
