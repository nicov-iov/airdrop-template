// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Administrable.sol";
import "./OpenAirdropERC20.sol";
import "./CustomAirdrop1155.sol";
import "./CustomAirdrop1155ClaimMerkle.sol";
import "./Types.sol";

contract AirdropManager is Administrable {
    address[] _airdrops;

    constructor (address[] memory initialAdmins) Administrable(initialAdmins) {}

    event AirdropAdded(address airdropAddress);
    event AirdropRemoved(address airdropAddress);
    event AirdropERC20Deployed(address airdropAddress);
    event AirdropERC1155Deployed(address airdropAddress);

    function claim(address airdropAddress, address user, uint256 amount, bytes32[] calldata proof) public {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        airdrop.claim(user, amount, proof);
    }

    function hasClaimed(address airdropAddress, address user) public view returns(bool) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.hasClaimed(user);
    }

    function hasExpired(address airdropAddress) public view returns(bool) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.hasExpired();
    }

    function isAllowed(address airdropAddress, address user) public view returns(bool) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.isAllowed(user);
    }

    function getExpirationDate(address airdropAddress) public view returns(uint256) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.getExpirationDate();
    }

    function getClaimAmount(address airdropAddress) public view returns(uint256) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.getClaimAmount();
    }

    function getAirdropInfo(address airdropAddress) public view returns(AirdropInfo memory) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.getAirdropInfo();
    }

    function getTotalAirdropAmount(address airdropAddress) public view returns(uint256) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.getTotalAirdropAmount();
    }

    function getAirdropAmountLeft(address airdropAddress) public view returns(uint256) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.getAirdropAmountLeft();
    }

    function getBalance(address airdropAddress) public view returns(uint256) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.getBalance();
    }

    function getAirdrops() public view returns(address[] memory) {
        return _airdrops;
    }

    function deployAndAddAirdrop(
        string memory airdropName,
        address tokenAddress,
        uint256 tokenId,
        uint256 totalAirdropAmount,
        uint256 claimAmount,
        uint256 expirationDate,
        uint256 mode,
        AirdropType airdropType
    ) public returns(address) {
        if(mode == 0) {
            OpenAirdropERC20 deployedAirdrop = new OpenAirdropERC20(
                airdropName, 
                address(this), 
                tokenAddress, 
                totalAirdropAmount, 
                claimAmount, 
                expirationDate
            );
            address airdropAddress = address(deployedAirdrop);

            emit AirdropERC20Deployed(airdropAddress);
            addAirdrop(airdropAddress);
            return airdropAddress;
        } else if (mode == 1) {
            CustomAirdrop1155 deployedAirdrop = new CustomAirdrop1155(
                airdropName,
                address(this),
                tokenAddress,
                tokenId,
                totalAirdropAmount,
                claimAmount,
                expirationDate,
                airdropType
            );
            address airdropAddress = address(deployedAirdrop);
            emit AirdropERC1155Deployed(airdropAddress);
            addAirdrop(airdropAddress);
            return airdropAddress;
        } else if (mode == 2) {
            CustomAirdrop1155Merkle deployedAirdrop = new CustomAirdrop1155Merkle(
                airdropName,
                address(this),
                tokenAddress,
                tokenId,
                totalAirdropAmount,
                expirationDate,
                airdropType
            );
            address airdropAddress = address(deployedAirdrop);
            emit AirdropERC1155Deployed(airdropAddress);
            addAirdrop(airdropAddress);
        } else {
            return address(0);
        }
    }

    function addAirdrop(address newAirdropAddress) public onlyAdmins {
        bool exists = false;
        for (uint i = 0; i < _airdrops.length && !exists; i++) {
            exists = _airdrops[i] == newAirdropAddress;
        }

        require(!exists, "Airdrop already added");
        _airdrops.push(newAirdropAddress);
        emit AirdropAdded(newAirdropAddress);
    }

    function setRoot(address airdropAddress, bytes32 _root) public onlyAdmins {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        airdrop.setRoot(_root);
    }

    function removeAirdrop(address airdropAddress) public onlyAdmins {
        bool exists = false;
        for (uint i = 0; i < _airdrops.length && !exists; i++) {
            if (_airdrops[i] == airdropAddress) {
                exists = true;
                _airdrops[i] = _airdrops[_airdrops.length -1];
                _airdrops.pop();
            }
        }

        if (exists) emit AirdropRemoved(airdropAddress);
    }

    function allowAddress(address airdropAddress, address user) public onlyAdmins {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        airdrop.allowAddress(user);
    }

    function allowAddresses(address airdropAddress, address[] memory users) public onlyAdmins {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        airdrop.allowAddresses(users);
    }

    function disallowAddress(address airdropAddress, address user) public onlyAdmins {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        airdrop.disallowAddress(user);
    }

    function disallowAddresses(address airdropAddress, address[] memory users) public onlyAdmins {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        airdrop.disallowAddresses(users);
    }
}