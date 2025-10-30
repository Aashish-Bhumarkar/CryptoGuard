    
    /**
     * @dev Core Function 2: Release a protected asset back to owner
     * @param _assetId Unique identifier for the asset to release
     */
    function releaseAsset(uint256 _assetId) public onlyAssetOwner(_assetId) {
        require(protectedAssets[_assetId].isActive, "Asset is not active");
        
        ProtectedAsset storage asset = protectedAssets[_assetId];
        uint256 valueToReturn = asset.assetValue;
        
        asset.isActive = false;
        totalAssetsProtected--;
        
        payable(msg.sender).transfer(valueToReturn);
        emit AssetReleased(_assetId, msg.sender);
    }
    
    /**
     * @dev Core Function 3: Verify asset security status
     * @param _assetId Unique identifier for the asset
     * @return bool Returns true if asset is protected and active
     */
    function verifyAssetSecurity(uint256 _assetId) public returns (bool) {
        require(protectedAssets[_assetId].isActive, "Asset is not active");
        
        ProtectedAsset memory asset = protectedAssets[_assetId];
        bool isSecure = asset.isActive && asset.assetValue > 0;
        
        if (isSecure) {
            emit SecurityCheckPassed(_assetId, block.timestamp);
        }
        
        return isSecure;
    }
    
    /**
     * @dev Get details of a protected asset
     * @param _assetId Unique identifier for the asset
     */
    function getAssetDetails(uint256 _assetId) public view returns (
        address assetOwner,
        uint256 assetValue,
        uint256 timestamp,
        bool isActive
    ) {
        ProtectedAsset memory asset = protectedAssets[_assetId];
        return (asset.assetOwner, asset.assetValue, asset.timestamp, asset.isActive);
    }
    
    /**
     * @dev Get contract balance
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
