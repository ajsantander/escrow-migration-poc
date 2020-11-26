pragma solidity ^0.5.16;


contract Test {
    uint64[52] _timestamps;
    uint256[52] _amounts;

    bytes _packedData;

    function setDataRaw(uint64[52] calldata timestamps, uint256[52] calldata amounts) external {
        _timestamps = timestamps;
        _amounts = amounts;
    }

    function setDataPacked(bytes calldata data) external {
        _packedData = data;
    }

    function unpackData() public {
        assembly {
            // Load free memory pointer
            let ptr = mload(0x40);

        }
    }

    function getTimestamps() public view returns (uint64[52] memory) {
        return _timestamps;
    }

    function getAmounts() public view returns (uint256[52] memory) {
        return _amounts;
    }
}
