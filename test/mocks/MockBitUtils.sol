// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {BitUtils} from "../../src/utils/BitUtils.sol";

contract MockBitUtils {
    using BitUtils for uint256;

    function isPow2(uint256 n,) external pure returns (bool) {
        return n.isPow2();
    }

    function roundUpToNearestPowerOf2(uint256 n, uint256 p2) external pure returns (uint256) {
        return n.roundUpToNearestPowerOf2(p2);
    }

    function reverseBits(uint256 n) external pure returns (uint256) {
        return n.reverseBits();
    }

    function reverseBytes(uint256 n) external pure returns (uint256) {
        return n.reverseBytes();
    }

    function countBitsSet(uint256 n) external pure returns (uint256) {
        return n.countBitsSet();
    }

    function extractBits(uint256 n, uint256 o, uint256 l) external pure returns (uint256) {
      return n.extractBits(o, l);
    }

    function setBits(
      uint256 n,
      uint256 v,
      uint256 o,
      uint256 l
    ) external pure returns (uint256) {
      return n.setBits(v, o, l);
    }

}
