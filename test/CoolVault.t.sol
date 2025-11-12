// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {CoolVault} from "../src/CoolVault.sol";
import {MacDonald} from "../src/MacDonald.sol";

contract CoolVaultTest is Test {
    CoolVault public coolVault;
    MacDonald public asset;

    // produce prank user addresses
    address public alice = address(1);
    address public bob = address(2);

    function setUp() public {
        asset = new MacDonald();
        coolVault = new CoolVault(asset, "stakedFrenchFries", "sFF");
    }

    function test_Asset() public {
        assertEq(coolVault.asset(), address(asset));
    }

    function test_Deposit() public {
        // mint some asset tokens to Alice
        vm.prank(alice);
        asset.mint(alice, 1000 ether);
        console.log(
            "Alice asset balance before deposit:",
            asset.balanceOf(alice) / 1 ether
        );

        // Alice deposits 100 asset tokens into the vault
        vm.startPrank(alice);
        asset.approve(address(coolVault), 100 ether);
        coolVault.deposit(100 ether, alice);
        console.log(
            "Alice asset balance after deposit:",
            asset.balanceOf(alice) / 1 ether
        );
        console.log(
            "Alice sFF balance after deposit:",
            coolVault.balanceOf(alice) / 1 ether
        );
        vm.stopPrank();

        // Assertions
        assertEq(asset.balanceOf(alice), 900 ether);
        assertEq(coolVault.balanceOf(alice), 100 ether);
    }

    function test_Redeem() public {
        // mint some asset tokens to Bob
        vm.prank(bob);
        asset.mint(bob, 500 ether);

        // Bob deposits 200 asset tokens into the vault
        vm.startPrank(bob);
        asset.approve(address(coolVault), 200 ether);
        coolVault.deposit(200 ether, bob);

        console.log(
            "Bob asset balance after deposit:",
            asset.balanceOf(bob) / 1 ether
        );
        console.log(
            "Bob sFF balance after deposit:",
            coolVault.balanceOf(bob) / 1 ether
        );

        // Bob redeems 50 sFF tokens from the vault
        coolVault.redeem(50 ether, bob, bob);

        console.log(
            "Bob asset balance after redeem:",
            asset.balanceOf(bob) / 1 ether
        );
        console.log(
            "Bob sFF balance after redeem:",
            coolVault.balanceOf(bob) / 1 ether
        );
        vm.stopPrank();

        // Assertions
        assertEq(asset.balanceOf(bob), 350 ether);
        assertEq(coolVault.balanceOf(bob), 150 ether);

        // test invariant: totalAssets should equal asset balance of the vault
        assertEq(coolVault.totalAssets(), asset.balanceOf(address(coolVault)));
    }
}
