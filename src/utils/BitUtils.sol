// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// Efficient bit manipulation library, note that checks are expected to be performed on "userland"
library BitUtils {
    // Parallelization masks
    uint256 private constant _M1 = 0x5555555555555555555555555555555555555555555555555555555555555555;
    uint256 private constant _M2 = 0x3333333333333333333333333333333333333333333333333333333333333333;
    uint256 private constant _M4 = 0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F;
    uint256 private constant _M8 = 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF;
    uint256 private constant _M16 = 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF;
    uint256 private constant _M32 = 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF;
    uint256 private constant _M64 = 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF;
    uint256 private constant _M128 = 0x00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    // Efficiently checks if `n` number is power of 2
    function isPow2(uint256 n) external pure returns (bool r) {
        /// @solidity memory-safe-assembly
        assembly {
            if gt(n, 0) {
               r := iszero(and(n, sub(n, 1)))
            }
        }
    }

   // Rounds `n` up to the nearest given power of 2 `p2`
   // Won"t perform check if `p2` is power of 2
   // Won't either check if `n` > `p2`
    function roundUpToNearestPowerOf2(
        uint256 n,
        uint256 p2
    ) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := sub(p2, 1)

            r := and(add(n, m), not(m))
        }
    }

    // Reverses bits in `n` using parallelization
    function reverseBits(uint256 n) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Reverse swapping pairs, nibles, bytes ...
            n := or(and(shr(1, n), _M1), shl(1, and(n, _M1)))
            n := or(and(shr(2, n), _M2), shl(2, and(n, _M2)))
            n := or(and(shr(4, n), _M4), shl(4, and(n, _M4)))
            n := or(and(shr(8, n), _M8), shl(8, and(n, _M8)))
            n := or(and(shr(16, n), _M16), shl(16, and(n, _M16)))
            n := or(and(shr(32, n), _M32), shl(32, and(n, _M32)))
            n := or(and(shr(64, n), _M64), shl(64, and(n, _M64)))
            r := or(and(shr(128, n), _M128), shl(128, and(n, _M128)))
        }
    }

    // Reverses bytes in `n` using parallelization
    function reverseBytes(uint256 n) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Reverse swapping bytes, 2bytes, 4bytes...
            n := or(and(shr(8, n), _M8), shl(8, and(n, _M8)))
            n := or(and(shr(16, n), _M16), shl(16, and(n, _M16)))
            n := or(and(shr(32, n), _M32), shl(32, and(n, _M32)))
            x := or(and(shr(64, n), _M64), shl(64, and(n, _M64)))
            r := or(shr(128, n), shl(128, n))
        }
    }

    // Counts number of bits set in `n`
    function countBitsSet(uint256 n) internal pure returns (uint256 r) {
        // TODO: Find an optimized impl, so far Solady's popcount seems to be the best
        /// @solidity memory-safe-assembly
        assembly {
            let max := eq(n, not(0))

            // Handle pairs, nibbles, bytes
            n := sub(n, and(shr(1, n), _M1))
            n := add(and(n, _M2), and(shr(2, n), _M2))
            n := and(add(n, shr(4, n)), _M4)

            // Sum bytes
            n := add(n, shr(8, n))
            n := add(n, shr(16, n))
            n := add(n, shr(32, n))
            n := add(n, shr(64, n))
            n := add(n, shr(128, n))

            r := add(shl(8, max), and(n, 0xFF))
        }
    }

    // Extracts `l` bits from `n` at offset `o`
    // Does not check if `o` > `n` bit length
    // Does not check if `l`  > `n` bit length
    function extractBits(uint256 n, uint256 o, uint256 l) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := and(shr(o, n), sub(shl(l, 1), 1))
        }
    }

    // Sets `l``bits of `n` at offset `o` with bits of `v`
    // Does not check if `o` > `n` bit length
    // Does not check if `l`  > `n` bit length`
    // Does not check if `v` > `l`
    function setBits(
        uint256 n,
        uint256 v,
         uint256 o,
         uint256 l
    ) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := shl(o, sub(shl(l, 1), 1))
            r := or(and(n, not(m)), and(shl(o, v), m))
        }
    }

    // Extracts `l` bytes from `n` at offset `o`
    // `n` is the number to extract bytes from
    // `o` is the byte offset
    // `l` is the number of bytes to extract
    function extractBytes(uint256 n, uint256 o, uint256 l) internal pure returns (uint256 r) {
        assembly {
            // Create a mask to extract `l` bytes
            let mask := sub(shl(mul(l, 8), 1), 1)
            // Shift `n` to right by `o` bytes and apply the mask
            r := and(shr(mul(o, 8), n), mask)
        }
    }

    // Sets `l` bytes of `n` at offset `o` with bytes of `v`
    // `n` is the number to modify
    // `v` is the value to insert
    // `o` is the byte offset
    // `l` is the number of bytes to set
    function setBytes(uint256 n, uint256 v, uint256 o, uint256 l) internal pure returns (uint256 r) {
        assembly {
            // Create a mask to clear the `l` bytes at offset `o`
            let mask := shl(mul(o, 8), sub(shl(mul(l, 8), 1), 1))
            let clearMask := not(mask)
            // Shift `v` to the correct position and apply the mask
            let shiftedValue := shl(mul(o, 8), v)
            r := or(and(n, clearMask), and(shiftedValue, mask))
        }
    }
}
