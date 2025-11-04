// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CryptoGraphy is ReentrancyGuard {
    struct ProtectedAsset {
        address assetOwner;
        uint256 assetValue;
        uint256 timestamp;
        bool isActive;
    }

    mapping(uint256 => ProtectedAsset) public protectedAssets;
    uint256 public totalAssetsProtected;

    event AssetProtected(uint256 indexed assetId, address indexed owner, uint256 value, uint256 timestamp);
    event AssetReleased(uint256 indexed assetId, address indexed owner, uint256 value);
    event SecurityCheckPassed(uint256 indexed assetId, uint256 timestamp);

    modifier onlyAssetOwner(uint256 _assetId) {
        require(protectedAssets[_assetId].assetOwner == msg.sender, "Not the asset owner");
        _;
    }

    function protectAsset(uint256 _assetId) external payable {
        require(msg.value > 0, "Asset value must be greater than zero");
        require(protectedAssets[_assetId].assetOwner == address(0), "Asset ID already exists");

        protectedAssets[_assetId] = ProtectedAsset({
            assetOwner: msg.sender,
            assetValue: msg.value,
            timestamp: block.timestamp,
            isActive: true
        });

        totalAssetsProtected++;
        emit AssetProtected(_assetId, msg.sender, msg.value, block.timestamp);
    }

    function releaseAsset(uint256 _assetId)
        external
        onlyAssetOwner(_assetId)
        nonReentrant
    {
        ProtectedAsset storage asset = protectedAssets[_assetId];
        require(asset.isActive, "Asset is not active");
        require(asset.assetValue > 0, "No value to release");

        uint256 valueToReturn = asset.assetValue;
        asset.isActive = false;
        asset.assetValue = 0;
        totalAssetsProtected--;

        (bool sent, ) = payable(msg.sender).call{value: valueToReturn}("");
        require(sent, "Transfer failed");

        emit AssetReleased(_assetId, msg.sender, valueToReturn);
    }

    function verifyAssetSecurity(uint256 _assetId) external view returns (bool) {
        ProtectedAsset memory asset = protectedAssets[_assetId];
        bool isSecure = asset.isActive && asset.assetValue > 0;
        return isSecure;
    }

    function getAssetDetails(uint256 _assetId)
        external
        view
        returns (address assetOwner, uint256 assetValue, uint256 timestamp, bool isActive)
    {
        ProtectedAsset memory asset = protectedAssets[_assetId];
        return (asset.assetOwner, asset.assetValue, asset.timestamp, asset.isActive);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
