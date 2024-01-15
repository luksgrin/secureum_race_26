// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {DeployQ2} from "script/q2.s.sol";

interface Q2 {
    function admin() external view returns (address);
    function deposit() external payable;
    function getBalance() external view returns (uint256);
    function kill() external;
    function setAdmin(address _admin) external;
    function transfer(address to, uint256 amount) external;
    function userBalances(address _address) external returns (uint256);
    function withdrawAll() external;
}


contract Q2Test is Test, DeployQ2 {
    Q2 public q2;

    function setUp() public override {
        q2 = Q2(deployQ2());
    }

    function test_general() external {

    }
}
