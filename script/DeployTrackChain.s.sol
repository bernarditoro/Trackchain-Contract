// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {TrackChain} from "../src/TrackChain.sol";

contract DeployTrackChain is Script {
    function run() external returns (TrackChain trackchain) {
        vm.startBroadcast();
        trackchain = new TrackChain();
        vm.stopBroadcast();
    }
}
