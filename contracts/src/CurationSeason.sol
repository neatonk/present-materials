// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title CurationManager
/// @notice Facilitates on-chain curation of a dynamic array of ethereum addresses
contract CurationManager is Ownable {
    /* ===== ERRORS ===== */

    /// @notice invalid curation pass
    error Access_MissingPass();

    /// @notice
    error Access_Unauthorized();

    /// @notice curation is inactive
    error Inactive();

    /// @notice curation is finalized
    error Finalized();

    /// @notice duplicate listing
    error ListingAlreadyExists();

    /// @notice exceeding curation limit
    error CurationLimitExceeded();

    /* ===== EVENTS ===== */
    event ListingAdded(address indexed curator, address indexed listingAddress);

    event ListingRemoved(
        address indexed curator,
        address indexed listingAddress
    );

    event TitleUpdated(address indexed sender, string title);

    event CurationPassUpdated(address indexed sender, address curationPass);

    event CurationPaused(address sender);

    event CurationResumed(address sender);

    event CurationFinalized(address sender);

    /* ===== VARIABLES ===== */

    address[] public listings;
    mapping(address => address) public listingCurators;

    string public title;
    IERC721 public curationPass;
    bool public isActive;
    bool public isFinalized = false;
    // unlimited curation limit if set to 0
    uint256 public curationLimit;

    /* ===== MODIFIERS ===== */

    modifier onlyOwnerOrCurator() {
        if (
            owner() != _msgSender() && curationPass.balanceOf(_msgSender()) == 0
        ) {
            revert Access_MissingPass();
        }

        _;
    }

    // checks if curation functionality is active
    modifier onlyIfActive() {
        if (isActive == false) {
            revert Inactive();
        }

        _;
    }

    // checks if curation functionality is finalized
    modifier onlyIfFinalized() {
        if (isFinalized == true) {
            revert Finalized();
        }

        _;
    }

    // checks if curation limit has been reached
    modifier onlyIfLimit() {
        if (curationLimit != 0 && listings.length == curationLimit) {
            revert CurationLimitExceeded();
        }

        _;
    }

    /* ===== CONSTRUCTOR ===== */

    constructor(
        string memory _title,
        IERC721 _curationPass,
        uint256 _curationLimit,
        bool _isActive
    ) {
        title = _title;
        curationPass = _curationPass;
        curationLimit = _curationLimit;
        isActive = _isActive;
        if (isActive == true) {
            emit CurationResumed(_msgSender());
        } else {
            emit CurationPaused(_msgSender());
        }
    }

    /* ===== CURATION FUNCTIONS ===== */

    /// @dev Explain to a developer any extra details
    /// @param listing parameter just like in doxygen (must be followed by parameter name)
    function addListing(address listing)
        external
        onlyIfActive
        onlyOwnerOrCurator
        onlyIfLimit
    {
        if (listingCurators[listing] != address(0)) {
            revert ListingAlreadyExists();
        }

        require(
            listing != address(0),
            "listing address cannot be the zero address"
        );

        listingCurators[listing] = _msgSender();

        listings.push(listing);

        emit ListingAdded(_msgSender(), listing);
    }

    /// @notice removes listing
    function removeListing(address listing)
        external
        onlyIfActive
        onlyOwnerOrCurator
    {
        if (
            owner() != _msgSender() && listingCurators[listing] != _msgSender()
        ) {
            revert Access_Unauthorized();
        }

        delete listingCurators[listing];
        removeByValue(listing);

        emit ListingRemoved(_msgSender(), listing);
    }

    /* ===== OWNER FUNCTIONS ===== */

    function updateTitle(string memory _title) public onlyOwner {
        title = _title;

        emit TitleUpdated(_msgSender(), _title);
    }

    function updateCurationPass(IERC721 _curationPass) public onlyOwner {
        curationPass = _curationPass;

        emit CurationPassUpdated(_msgSender(), address(_curationPass));
    }

    function updateCurationLimit(uint256 _newLimit) public onlyOwner {
        require(
            _newLimit > listings.length,
            "cannot set curationLimit to value equal to or smaller than current length of listings array"
        );
        curationLimit = _newLimit;

        // maybe add an emitted event here
    }

    function flipIsActiveBool() public onlyOwner {
        if (isActive == true) {
            isActive = false;
            emit CurationPaused(_msgSender());
        } else {
            isActive = true;
            emit CurationResumed(_msgSender());
        }
    }

    function finalizeCuration() public onlyOwner {
        if (isActive == false) {
            isFinalized == true;
            emit CurationFinalized(_msgSender());
            return;
        }

        isActive = false;
        emit CurationPaused(_msgSender());

        isFinalized = true;
        emit CurationFinalized(_msgSender());
    }

    // add listing functionality without isActive check
    function onwerAddListing(address listing)
        external
        onlyIfLimit
        onlyIfFinalized
        onlyOwner
    {
        if (listingCurators[listing] != address(0)) {
            revert ListingAlreadyExists();
        }

        require(
            listing != address(0),
            "listing address cannot be the zero address"
        );

        listingCurators[listing] = _msgSender();

        listings.push(listing);

        emit ListingAdded(_msgSender(), listing);
    }

    /// remove listing functionality without isActive or Access_Unauthorized check
    function ownerRemoveListing(address listing)
        external
        onlyIfFinalized
        onlyOwner
    {
        delete listingCurators[listing];
        removeByValue(listing);

        emit ListingRemoved(_msgSender(), listing);
    }

    /* ===== VIEW FUNCTIONS ===== */

    // view function that returns array of all active listings
    function viewAllListings() external view returns (address[] memory) {
        // returns empty array if no active listings
        return listings;
    }

    /* ===== INTERNAL HELPERS ===== */

    function find(address value) internal view returns (uint256) {
        uint256 i = 0;
        while (listings[i] != value) {
            i++;
        }
        return i;
    }

    function removeByIndex(uint256 index) internal {
        if (index >= listings.length) return;

        for (uint256 i = index; i < listings.length - 1; i++) {
            listings[i] = listings[i + 1];
        }

        listings.pop();
    }

    function removeByValue(address value) internal {
        uint256 i = find(value);
        removeByIndex(i);
    }
}
