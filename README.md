# TrackChain - Blockchain-Based Ownership Tracking

TrackChain is a decentralised, smart contract-based system for tracking the ownership history of items on the Base blockchain. Each item has a unique identifier, and its ownership is recorded securely and transparently, enabling immutable records of all transfers and verifiable ownership. The contract is publicly hosted at this address: [0xAA11a1Ca9CE13B9cb7B6ca00270Eeec27bA15287](https://sepolia.basescan.org/address/0xAA11a1Ca9CE13B9cb7B6ca00270Eeec27bA15287)

## Features

- **Add New Items**: Users can create new items on the blockchain with a unique identifier and an initial ownership record.
- **Transfer Ownership**: Ownership of an item can be securely transferred to another address.
- **Ownership History**: Retrieve the entire ownership history of an item, including all previous and current owners along with the date of each transfer.
- **Current Owner**: Easily get the current owner of any registered item.
- **Initial Owner**: Access the initial owner of any item to verify its origin.
- **Items by Owner**: Fetch all items currently owned by a specific wallet address.

## Contract Structure

### Data Structures

1. **OwnershipRecord**: Stores the current and previous owner, as well as the timestamp of the ownership transfer.
   ```solidity
   struct OwnershipRecord {
       address currentOwner;
       address previousOwner;
       uint256 dateTransferred;
   }
   ```

2. **Item**: Contains item details (name, itemId) and an array of `OwnershipRecord` to store the full ownership history.
   ```solidity
   struct Item {
       string name;
       string itemId;
       OwnershipRecord[] ownershipHistory;
   }
   ```

### State Variables

- `itemIds`: An array that stores the unique IDs of all items created.
- `items`: A mapping of `itemId` to the respective `Item` details.

### Functions

1. **createItem(string memory _itemId, string memory _name)**  
   Registers a new item with a unique ID and stores the initial ownership record.  
   - `_itemId`: The unique ID of the item (string).
   - `_name`: The name of the item.
   
   Example:
   ```solidity
   function createItem(string memory _itemId, string memory _name) public;
   ```

2. **transferOwnership(string memory _itemId, address _newOwner)**  
   Transfers the ownership of an item to a new owner.
   - `_itemId`: The unique ID of the item.
   - `_newOwner`: The address of the new owner.

   Example:
   ```solidity
   function transferOwnership(string memory _itemId, address _newOwner) public;
   ```

3. **getOwnershipHistory(string memory _itemId)**  
   Retrieves the complete ownership history of an item, including all transfers.
   - `_itemId`: The unique ID of the item.

   Example:
   ```solidity
   function getOwnershipHistory(string memory _itemId) public view returns (Item memory);
   ```

4. **getCurrentOwner(string memory _itemId)**  
   Returns the current owner of the specified item.
   - `_itemId`: The unique ID of the item.

   Example:
   ```solidity
   function getCurrentOwner(string memory _itemId) public view returns (address);
   ```

5. **getInitialOwner(string memory _itemId)**  
   Returns the initial owner of the item.
   - `_itemId`: The unique ID of the item.

   Example:
   ```solidity
   function getInitialOwner(string memory _itemId) public view returns (address);
   ```

6. **getItemsByOwner(address _ownerAddress)**  
   Retrieves all items currently owned by a specific wallet address.
   - `_ownerAddress`: The wallet address to check for ownership.

   Example:
   ```solidity
   function getItemsByOwner(address _ownerAddress) public view returns (Item[] memory);
   ```

## How It Works

### 1. Creating an Item
When a user creates an item, they call the `createItem` function, which takes the item ID and name as inputs. The creator is automatically recorded as the first owner in the item's ownership history.

### 2. Transferring Ownership
Owners can transfer their items to another address using the `transferOwnership` function. The contract ensures that only the current owner can initiate a transfer. A new ownership record is created, updating the item's history with the new owner's details and the transfer date.

### 3. Querying Ownership
Users can check the ownership history, current owner, or initial owner of any item by calling the respective functions (`getOwnershipHistory`, `getCurrentOwner`, `getInitialOwner`). Additionally, users can query all items owned by a specific wallet address using `getItemsByOwner`.

## Example Usage

1. **Create an item:**
   ```solidity
   createItem("item123", "Laptop");
   ```

2. **Transfer ownership:**
   ```solidity
   transferOwnership("item123", newOwnerAddress);
   ```

3. **Get current owner:**
   ```solidity
   address owner = getCurrentOwner("item123");
   ```

4. **Get all items owned by an address:**
   ```solidity
   Item[] memory itemsOwned = getItemsByOwner(ownerAddress);
   ```

## License

This project is licensed under the MIT License.