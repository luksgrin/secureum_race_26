// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {SnekSmith} from "src/SnekSmith.sol";

contract DeployQ2 is Script, SnekSmith {
    function setUp() public virtual {}

    function deployQ2() public returns(address) {
        return createContract(
            "src/",
            "q2"
        );
    }

    function run() public returns(address q2) {
        vm.broadcast();
        q2 = deployQ2();
    }
}
