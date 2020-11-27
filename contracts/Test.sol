pragma solidity ^0.5.16;


contract Test {
    uint64[52] _timestamps;
    uint256[52] _amounts;

    bytes _packedData;
    bytes _superPackedData;

    function setDataRaw(uint64[52] calldata timestamps, uint256[52] calldata amounts) external {
        _timestamps = timestamps;
        _amounts = amounts;
    }

    function getTimestamps() public view returns (uint64[52] memory) {
        return _timestamps;
    }

    function getAmounts() public view returns (uint256[52] memory) {
        return _amounts;
    }

    // -----------------------------
    // Simple packing
    // -----------------------------

    function setPackedData(bytes calldata packedData) external {
        _packedData = packedData;
    }

    function unpackData() public {
        (_timestamps, _amounts) = abi.decode(_packedData, (uint64[52], uint256[52]));
    }

    // -----------------------------
    // Super packing
    // -----------------------------

    function setSuperPackedData(bytes calldata data) external {
        _superPackedData = data;
    }

    function getSuperPackedData() external view returns (bytes memory) {
        return _superPackedData;
    }

    function superUnpackData() public {
        bytes memory packed = _superPackedData;

        uint len;
        uint offset;

        for (uint i = 0; i < 52; i++) {

            // ------------------
            // Decode timestamp
            // ------------------

            len = toUint8(packed, offset);
            offset += 1;

            if (len == 1) {
                _timestamps[i] = uint64(toUint8(packed, offset));
                offset += 1;
            } else if (len == 2) {
                _timestamps[i] = uint64(toUint16(packed, offset));
                offset += 2;
            } else if (len == 3) {
                _timestamps[i] = uint64(toUint24(packed, offset));
                offset += 3;
            } else if (len == 4) {
                _timestamps[i] = uint64(toUint32(packed, offset));
                offset += 4;
            } else {
                revert("Unsupported size");
            }

            // ------------------
            // Decode amount
            // ------------------

            len = toUint8(packed, offset);
            offset += 1;

            if (len == 1) {
                _amounts[i] = uint(toUint8(packed, offset));
                offset += 1;
            } else if (len == 2) {
                _amounts[i] = uint(toUint16(packed, offset));
                offset += 2;
            } else if (len == 3) {
                _amounts[i] = uint(toUint24(packed, offset));
                offset += 3;
            } else if (len == 4) {
                _amounts[i] = uint(toUint32(packed, offset));
                offset += 4;
            } else {
                revert("Unsupported size");
            }
        }
    }

    // --------------------------------
    // Encoding utils
    // --------------------------------

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {
        require(_start + 1 >= _start, "toUint8_overflow");
        require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
        require(_start + 2 >= _start, "toUint16_overflow");
        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
        require(_start + 3 >= _start, "toUint24_overflow");
        require(_bytes.length >= _start + 3, "toUint24_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {
        require(_start + 4 >= _start, "toUint32_overflow");
        require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }
}
