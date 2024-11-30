// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract TrackChain {
    // State variables
    string[] private itemIds; // TODO: Implement a better way to store itemIds
    mapping(string itemId => Item item) private items;

    struct OwnershipRecord {
        address currentOwner;
        address previousOwner;
        uint256 dateTransferred;
    }

    struct Item {
        string name;
        OwnershipRecord[] ownershipHistory; // Array to store multiple records
    }
    // End State Variables

    // Errors
    error TrackChain__ItemNotFound();
    error TrackChain__TransferNotPermitted();
    error TrackChain__DuplicateItemsNotAllowed();
    error TrackChain__EmptyItemPropertiesNotAllowed();
    error TrackChain__CannotTransferToSelf();

    // Modifiers
    modifier onlyOwnerCanTransfer(string memory _itemId) {
        // Only owner can transfer item
        address currentOwner = getCurrentOwner(_itemId);

        if (currentOwner != msg.sender) revert TrackChain__TransferNotPermitted();

        _;
    }

    modifier cannotAddDuplicateItem(string memory itemId) {
        Item memory item = items[itemId];

        if (bytes(item.name).length != 0 && item.ownershipHistory.length != 0) {
            revert TrackChain__DuplicateItemsNotAllowed();
        }
        _;
    }

    modifier noEmptyParameters(string memory itemId, string memory name) {
        if (bytes(itemId).length == 0 || bytes(name).length == 0) revert TrackChain__EmptyItemPropertiesNotAllowed();
        _;
    }

    modifier isListed(string memory itemId) {
        Item memory item = items[itemId];
        if (item.ownershipHistory.length == 0) revert TrackChain__ItemNotFound();

        _;
    }

    modifier noTransferToCurrentOwner(string memory itemId, address newOwner) {
        address currentOwner = getCurrentOwner(itemId);
        if (currentOwner == newOwner) revert TrackChain__CannotTransferToSelf();

        _;
    }
    // End Modifiers

    //Events
    event ItemCreated(string indexed itemId, string indexed name);
    event ItemOwnershipTransferred(
        string indexed itemId, address previousOwner, address currentOwner, uint256 dateTransferred
    );
    // End Events

    function createItem(string memory _itemId, string memory _name)
        public
        cannotAddDuplicateItem(_itemId)
        noEmptyParameters(_itemId, _name)
    {
        OwnershipRecord memory initialRecord = OwnershipRecord({
            currentOwner: msg.sender,
            previousOwner: address(0), // No previous owner for a new item
            dateTransferred: block.timestamp
        });

        emit ItemCreated(_itemId, _name);

        items[_itemId].name = _name;
        items[_itemId].ownershipHistory.push(initialRecord);

        itemIds.push(_itemId);
    }

    function transferOwnership(string memory _itemId, address _newOwner)
        public
        isListed(_itemId)
        onlyOwnerCanTransfer(_itemId)
        noTransferToCurrentOwner(_itemId, _newOwner)
    {
        Item storage item = items[_itemId];

        // Get the last record to update ownership
        OwnershipRecord memory newRecord =
            OwnershipRecord({currentOwner: _newOwner, previousOwner: msg.sender, dateTransferred: block.timestamp});

        emit ItemOwnershipTransferred(_itemId, msg.sender, _newOwner, block.timestamp);

        // Add the new ownership record to the item
        item.ownershipHistory.push(newRecord);
    }

    function getCurrentOwner(string memory _itemId) public view isListed(_itemId) returns (address) {
        Item storage item = items[_itemId];
        return item.ownershipHistory[item.ownershipHistory.length - 1].currentOwner;
    }

    function getInitialOwner(string memory _itemId) public view isListed(_itemId) returns (address) {
        Item storage item = items[_itemId];
        return item.ownershipHistory[0].currentOwner;
    }

    function getItemsByOwner(address _ownerAddress) external view returns (Item[] memory) {
        Item[] memory ownedItems = new Item[](itemIds.length);
        uint256 count = 0;

        for (uint256 i = 0; i < itemIds.length; i++) {
            string memory itemId = itemIds[i];
            Item storage item = items[itemId];

            // Check if address is current owner
            address currentOwner = getCurrentOwner(itemId);

            if (currentOwner == _ownerAddress) {
                ownedItems[count] = item;
                count++;
            }
        }

        // Create a new array with the correct size to return
        Item[] memory result = new Item[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = ownedItems[i];
        }

        return result;
    }

    function getItemIds() external view returns (string[] memory) {
        return itemIds;
    }

    function getOwnershipHistory(string memory _itemId) external view returns (Item memory) {
        return items[_itemId];
    }
}
