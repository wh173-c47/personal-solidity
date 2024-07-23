// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {MockBitUtils} from "../mocks/MockBitUtils.sol";

// TODO: Develop tests, add edge test cases
contract BitUtilsTest is Test {
    MockBitUtils private ctr;

    function setUp() public {
        ctr = new MockBitUtils();
    }

    function testIsPow2() public {
    }

    function testRoundUpToNearestPowerOf2() public {
    }

    function testReverseBits() public {
    }

    function testReverseBytes() public {
    }

    function testCountBitsSet() public {
    }

    function testExtractBits() public {
    }

    function testSetBits() public {
    }
}
