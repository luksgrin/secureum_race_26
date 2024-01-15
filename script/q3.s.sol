// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {SnekSmith} from "src/SnekSmith.sol";

contract DeployQ3 is Script, SnekSmith {
    function setUp() public virtual {}

    function deployQ3() public returns(address) {
        return createContract(
            "src/",
            "q3"
        );
    }

    function run() public returns(address q3) {
        vm.broadcast();
        q3 = deployQ3();
    }
}
