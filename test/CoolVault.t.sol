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
        console.log("Alice asset balance before deposit:", asset.balanceOf(alice) / 1 ether);

        // Alice deposits 100 asset tokens into the vault
        vm.startPrank(alice);
        asset.approve(address(coolVault), 100 ether);
        coolVault.deposit(100 ether, alice);
        console.log("Alice asset balance after deposit:", asset.balanceOf(alice) / 1 ether);
        console.log("Alice sFF balance after deposit:", coolVault.balanceOf(alice) / 1 ether);
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

        console.log("Bob asset balance after deposit:", asset.balanceOf(bob) / 1 ether);
        console.log("Bob sFF balance after deposit:", coolVault.balanceOf(bob) / 1 ether);

        // Bob redeems 50 sFF tokens from the vault
        coolVault.redeem(50 ether, bob, bob);

        console.log("Bob asset balance after redeem:", asset.balanceOf(bob) / 1 ether);
        console.log("Bob sFF balance after redeem:", coolVault.balanceOf(bob) / 1 ether);
        vm.stopPrank();

        // Assertions
        assertEq(asset.balanceOf(bob), 350 ether);
        assertEq(coolVault.balanceOf(bob), 150 ether);

        // test invariant: totalAssets should equal asset balance of the vault
        assertEq(coolVault.totalAssets(), asset.balanceOf(address(coolVault)));
    }

    function test_ConvertToSharesEqualPreviewDeposit() public {
        // Alice mint some asset tokens
        vm.prank(alice);
        asset.mint(alice, 300 ether);

        // Alice deposits 200 asset tokens into the vault
        vm.startPrank(alice);
        asset.approve(address(coolVault), 300 ether);
        coolVault.deposit(300 ether, alice);
        vm.stopPrank();

        // Assertions
        assertEq(coolVault.convertToShares(200 ether), coolVault.previewDeposit(200 ether));
    }

    function test_ConvertToAssetsEqualPreviewRedeem() public {
        // Bob mint some asset tokens
        vm.prank(bob);
        asset.mint(bob, 400 ether);

        // Bob deposits 200 asset tokens into the vault
        vm.startPrank(bob);
        asset.approve(address(coolVault), 400 ether);
        coolVault.deposit(400 ether, bob);
        vm.stopPrank();

        // Assertions
        assertEq(coolVault.convertToAssets(100 ether), coolVault.previewRedeem(100 ether));
    }

    function test_Fuzz(uint256 depositAmount, uint256 redeemAmount) public {
        // Fuzz test deposit and redeem
        depositAmount = bound(depositAmount, 0 ether, 99999 ether);
        redeemAmount = bound(redeemAmount, 0 ether, depositAmount);

        // Alice mint some asset tokens
        vm.prank(alice);
        asset.mint(alice, depositAmount + 666 ether);

        // Alice deposits asset tokens into the vault
        vm.startPrank(alice);
        uint256 computeShares = coolVault.convertToShares(depositAmount);
        asset.approve(address(coolVault), depositAmount);
        coolVault.deposit(depositAmount, alice);

        // Alice redeems some sFF tokens from the vault
        uint256 assetOut = coolVault.redeem(redeemAmount, alice, alice);
        vm.stopPrank();

        // Assertions
        assertEq(assetOut, redeemAmount);
        assertEq(coolVault.balanceOf(alice), depositAmount - redeemAmount);
        assertEq(asset.balanceOf(alice), 666 ether + redeemAmount);
    }

    function test_ConvertToSharesLessEqualPreviewDeposit() public {
        // Alice mint some asset tokens
        vm.prank(alice);
        asset.mint(alice, 300 ether);

        // Alice deposits 200 asset tokens into the vault
        vm.startPrank(alice);
        asset.approve(address(coolVault), 300 ether);
        coolVault.deposit(300 ether, alice);
        vm.stopPrank();

        // Assertions
        assertLe(coolVault.convertToShares(200 ether), coolVault.previewDeposit(200 ether));
    }
}
