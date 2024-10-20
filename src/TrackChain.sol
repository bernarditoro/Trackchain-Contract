// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TrackChain {

    // Struct for ownership record
    struct OwnershipRecord {
        address currentOwner;
        address previousOwner;
        uint256 dateTransferred;
    }

    // Struct for an item
    struct Item {
        string name;
        string itemId;
        OwnershipRecord[] ownershipHistory;  // Array to store multiple records
    }

    string[] public itemIds;

    // Mapping of item ID (string) to item details
    mapping(string => Item) public items;

    // Function to create a new item
    function createItem(string memory _itemId, string memory _name) public {
        OwnershipRecord memory initialRecord = OwnershipRecord({
            currentOwner: msg.sender,
            previousOwner: address(0),  // No previous owner for a new item
            dateTransferred: block.timestamp
        });
        
        items[_itemId].name = _name;
        items[_itemId].itemId = _itemId;
        items[_itemId].ownershipHistory.push(initialRecord);

        itemIds.push(_itemId);
    }

    // Function to transfer ownership
    function transferOwnership(string memory _itemId, address _newOwner) public {
        Item storage item = items[_itemId];
        require(item.ownershipHistory.length > 0, "Item not found");
        
        // Only owner can transfer item
        address currentOwner = getCurrentOwner(item.itemId);
        require(currentOwner == msg.sender, "Only current owner can initiaite transfer");

        // Get the last record to update ownership
        OwnershipRecord memory newRecord = OwnershipRecord({
            currentOwner: _newOwner,
            previousOwner: item.ownershipHistory[item.ownershipHistory.length - 1].currentOwner,
            dateTransferred: block.timestamp
        });

        // Add the new ownership record to the item
        item.ownershipHistory.push(newRecord);
    }

    // Function to retrieve ownership history of an item
    function getOwnershipHistory(string memory _itemId) public view returns (Item memory) {
        return items[_itemId];
    }

    // Function to retrieve current owner of an item
    function getCurrentOwner(string memory _itemId) public view returns (address) {
        Item storage item = items[_itemId];
        require(item.ownershipHistory.length > 0, "Item not found");
        return item.ownershipHistory[item.ownershipHistory.length - 1].currentOwner;
    }

    // Function to retrieve initial owner of an item
    function getInitialOwner(string memory _itemId) public view returns (address) {
        Item storage item = items[_itemId];
        require(item.ownershipHistory.length > 0, "Item not found");
        return item.ownershipHistory[0].currentOwner;
    }

    function getItemsByOwner(address _ownerAddress) public view returns (Item[] memory) {
        Item[] memory ownedItems = new Item[](itemIds.length);
        uint count = 0;

        for (uint i = 0; i < itemIds.length; i++) {
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
        for (uint i = 0; i < count; i++) {
            result[i] = ownedItems[i];
        }

        return result;
    }
}

