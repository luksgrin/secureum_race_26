// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {SnekSmith} from "src/SnekSmith.sol";

contract DeployQ1 is Script, SnekSmith {
    function setUp() public virtual {}

    function deployQ1() public returns(address) {
        return createContract(
            "src/",
            "q1"
        );
    }

    function run() public returns(address q1) {
        vm.broadcast();
        q1 = deployQ1();
    }
}
