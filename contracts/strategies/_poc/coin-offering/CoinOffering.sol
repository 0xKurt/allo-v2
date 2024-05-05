// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.19;

// External Libraries
import {Multicall} from "openzeppelin-contracts/contracts/utils/Multicall.sol";
// Interfaces
import {IRegistry} from "../../../core/interfaces/IRegistry.sol";
// Core Contracts
import {BaseStrategy} from "../../BaseStrategy.sol";
// Internal Libraries
import {Metadata} from "../../../core/libraries/Metadata.sol";
import {Native} from "../../../core/libraries/Native.sol";

// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⢿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⡟⠘⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣾⣿⣿⣿⣿⣾⠻⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⡿⠀⠀⠸⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⢀⣠⣴⣴⣶⣶⣶⣦⣦⣀⡀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⡿⠃⠀⠙⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⠁⠀⠀⠀⢻⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⡀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠘⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⠃⠀⠀⠀⠀⠈⢿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⣰⣿⣿⣿⡿⠋⠁⠀⠀⠈⠘⠹⣿⣿⣿⣿⣆⠀⠀⠀
// ⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⢰⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⡀⠀⠀
// ⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣟⠀⡀⢀⠀⡀⢀⠀⡀⢈⢿⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀
// ⠀⠀⣠⣿⣿⣿⣿⣿⣿⡿⠋⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⡿⢿⠿⠿⠿⠿⠿⠿⠿⠿⠿⢿⣿⣿⣿⣷⡀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠸⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⠂⠀⠀
// ⠀⠀⠙⠛⠿⠻⠻⠛⠉⠀⠀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣧⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⢻⣿⣿⣿⣷⣀⢀⠀⠀⠀⡀⣰⣾⣿⣿⣿⠏⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣧⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠹⢿⣿⣿⣿⣿⣾⣾⣷⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠙⠋⠛⠙⠋⠛⠙⠋⠛⠙⠋⠃⠀⠀⠀⠀⠀⠀⠀⠀⠠⠿⠻⠟⠿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠟⠿⠟⠿⠆⠀⠸⠿⠿⠟⠯⠀⠀⠀⠸⠿⠿⠿⠏⠀⠀⠀⠀⠀⠈⠉⠻⠻⡿⣿⢿⡿⡿⠿⠛⠁⠀⠀⠀⠀⠀⠀
//                    allo.gitcoin.co

// Quick description:
// Recipients can offer coins to the pool, pool managers can review the offering and approve or reject it based on a threshold during the review period.
// Allocators can then allocate the pool token to the recipient and buy the offered token from the recipient.
// Claiming starts after the offering period ends and the recipient can claim the offering token.
// If too many tokens were allocated, the allocator will be able to claim the excess tokens and recives a smaller amount of the offering token. (fair distribution)
// pool managers (later gov token holder) receive a reward of governanceReward% for their work as reviewers.

// Todo:
// add safety period for time between offering and claiming and the governance around it
// add reviewer == governance token holder instead of pool managers

/// @title Direct Grants Lite Strategy
/// @author @thelostone-mc <aditya@gitcoin.co>, @0xKurt <kurt@gitcoin.co>, @codenamejason <jason@gitcoin.co>
/// @notice Strategy for coin offerings
contract CoinOfferingStrategy is Native, BaseStrategy, Multicall {
    /// @notice Stores the initialize data for the strategy
    struct InitializeData {
        bool useRegistryAnchor;
        bool metadataRequired;
        IRegistry registry;
        uint256 governanceReward; // reward for governance token holders, 1e18 represents 100%
        uint256 reviewThreshold; // e.g: 6e17 for min 60% approvals or rejections, 1e18 represents 100%
        uint64 reviewsNeeded; // min number of reviews needed to decide
        uint64 reviewPeriod; // time period for reviews (in seconds)
        uint64 maxOfferingPeriod; // time period for offering (in seconds)
    }

    struct Review {
        uint256 approvals;
        uint256 rejections;
        uint256 totalReviews;
        uint256 reviewStartDate;
        uint256 reviewEndDate;
        mapping(address => uint256) reviewed;
    }

    struct Allocations {
        uint256 totalAllocations;
        mapping(address => uint256) userAllocations;
    }

    /// @notice Stores the data of a recipient
    struct Recipient {
        address recipientId;
        bool useRegistryAnchor;
        address recipientAddress;
        Metadata metadata;
        uint256 offeringStartDate;
        uint256 offeringEndDate;
        uint256 offeringAmount;
        address tokenAddress;
        uint256 tokenPrice;
        uint256 maxAllocationPerUser; // in pool token
    }

    mapping(address => Recipient) public recipients;
    mapping(address => Review) public reviews;
    mapping(address => Allocations) public allocations;

    /// ================================
    /// ========== Storage =============
    /// ================================

    /// @notice Pool token
    address public poolToken;

    /// @notice Flag to indicate whether to use the registry anchor or not.
    bool public useRegistryAnchor;

    /// @notice Flag to indicate whether metadata is required or not.
    bool public metadataRequired;

    /// @notice The address of the registry
    IRegistry public registry;

    /// @notice The review threshold for the strategy
    uint256 public reviewThreshold;

    /// @notice The number of reviews needed to decide
    uint64 public reviewsNeeded;

    /// @notice The review period for the strategy
    uint64 public reviewPeriod;

    /// @notice The max offering period for the strategy
    uint64 public maxOfferingPeriod;

    /// ===============================
    /// ========== Errors =============
    /// ===============================

    error REVIEW_PERIOD_OVER();
    error REVIEWED_ALREADY();

    /// ===============================
    /// ========== Events =============
    /// ===============================

    /// @notice Emitted when the strategy is initialized
    event CoinOfferingStrategyInitialized(uint256 poolId, InitializeData initializeData);

    /// @notice Emitted when the registry is set
    event RegistrySet(address indexed sender, address indexed registry);

    /// @notice Emitted when the review threshold is set
    event ReviewThresholdSet(address indexed sender, uint256 reviewThreshold);

    /// @notice Emitted when the reviews needed is set
    event ReviewsNeededSet(address indexed sender, uint64 reviewsNeeded);

    /// @notice Emitted when the review period is set
    event ReviewPeriodSet(address indexed sender, uint64 reviewPeriod);

    /// @notice Emitted when the max offering period is set
    event MaxOfferingPeriodSet(address indexed sender, uint64 maxOfferingPeriod);

    /// @notice emitted when a recipient is registered
    event RecipientRegistered(
        address recipientId,
        address recipientAddress,
        Metadata metadata,
        uint256 offeringAmount,
        uint256 offeringPeriod,
        address tokenAddress,
        uint256 maxAllocationPerUser
    );

    /// ===============================
    /// ======== Constructor ==========
    /// ===============================

    /// @notice Constructor for the Direct Grants Lite Strategy
    /// @param _allo The 'Allo' contract
    /// @param _name The name of the strategy
    constructor(address _allo, string memory _name) BaseStrategy(_allo, _name) {}

    /// ===============================
    /// ========= Initialize ==========
    /// ===============================

    /// @notice Initializes the strategy
    /// @dev This will revert if the strategy is already initialized and 'msg.sender' is not the 'Allo' contract.
    /// @param _poolId The 'poolId' to initialize
    /// @param _data The data to be decoded to initialize the strategy
    /// @custom:data InitializeData(bool useRegistryAnchor, bool metadataRequired, uint256 reviewThreshold,
    ///                             uint64 reviewsNeeded, uint64 reviewPeriod, uint64 maxOfferingPeriod)
    function initialize(uint256 _poolId, bytes memory _data) external virtual override onlyAllo {
        InitializeData memory initializeData = abi.decode(_data, (InitializeData));
        __CoinOfferingStrategy_init(_poolId, initializeData);
        emit Initialized(_poolId, _data);
    }

    /// @notice Initializes the strategy
    /// @dev This will revert if the strategy is already initialized.
    /// @param _poolId The 'poolId' to initialize
    /// @param _initializeData The data to be decoded to initialize the strategy
    function __CoinOfferingStrategy_init(uint256 _poolId, InitializeData memory _initializeData) internal {
        // Initialize the base strategy
        __BaseStrategy_init(_poolId);

        // revert if a value is not set
        if (
            address(_initializeData.registry) == address(0) || _initializeData.reviewThreshold == 0
                || _initializeData.reviewsNeeded == 0 || _initializeData.reviewPeriod == 0
                || _initializeData.maxOfferingPeriod == 0
        ) {
            revert INVALID();
        }

        // Set the strategy data
        useRegistryAnchor = _initializeData.useRegistryAnchor;
        metadataRequired = _initializeData.metadataRequired;
        registry = _initializeData.registry;
        reviewThreshold = _initializeData.reviewThreshold;
        reviewsNeeded = _initializeData.reviewsNeeded;
        reviewPeriod = _initializeData.reviewPeriod;
        maxOfferingPeriod = _initializeData.maxOfferingPeriod;

        poolToken = allo.getPool(_poolId).token;

        emit CoinOfferingStrategyInitialized(_poolId, _initializeData);
    }

    // ==============================
    // ============ Core ============
    // ==============================

    function _registerRecipient(bytes memory _data, address _sender) internal override returns (address recipientId) {
        bool isUsingRegistryAnchor;
        address recipientAddress;
        Metadata memory metadata;
        uint256 offeringAmount;
        uint256 offeringPeriod;
        address tokenAddress; // token to distribute
        uint256 tokenPrice;
        uint256 maxAllocationPerUser; // in pool token

        // decode data custom to this strategy
        (
            recipientId,
            recipientAddress,
            metadata,
            offeringAmount,
            offeringPeriod,
            tokenAddress,
            tokenPrice,
            maxAllocationPerUser
        ) = abi.decode(_data, (address, address, Metadata, uint256, uint256, address, uint256, uint256));

        if (
            offeringPeriod > maxOfferingPeriod || offeringAmount == 0 || tokenAddress == address(0)
                || offeringPeriod == 0
        ) {
            revert INVALID();
        }

        // decode data custom to this strategy
        if (useRegistryAnchor) {
            // If the sender is not a profile member this will revert
            if (!_isProfileMember(recipientId, _sender)) {
                revert UNAUTHORIZED();
            }
        } else {
            // Set this to 'true' if the registry anchor is not the zero address
            isUsingRegistryAnchor = recipientId != address(0);

            // If using the 'recipientId' we set the 'recipientId' to the 'recipientId', otherwise we set it to the 'msg.sender'
            recipientId = isUsingRegistryAnchor ? recipientId : _sender;

            // Checks if the '_sender' is a member of the profile 'anchor' being used and reverts if not
            if (isUsingRegistryAnchor && !_isProfileMember(recipientId, _sender)) {
                revert UNAUTHORIZED();
            }
        }

        // If the metadata is required and the metadata is invalid this will revert
        if (metadataRequired && (bytes(metadata.pointer).length == 0 || metadata.protocol == 0)) {
            revert INVALID_METADATA();
        }

        // Get the recipient
        Recipient storage recipient = recipients[recipientId];
        // Get the review
        Review storage review = reviews[recipientId];

        // If the recipient address is the zero address this will revert
        if (recipientAddress == address(0) || review.totalReviews > 0) {
            revert RECIPIENT_ERROR(recipientId);
        }

        // update the recipients data
        recipient.recipientAddress = recipientAddress;
        recipient.metadata = metadata;
        recipient.useRegistryAnchor = useRegistryAnchor ? true : isUsingRegistryAnchor;
        recipient.recipientId = recipientId;
        recipient.offeringStartDate = block.timestamp + reviewPeriod;
        recipient.offeringEndDate = recipient.offeringStartDate + offeringPeriod;
        recipient.offeringAmount = offeringAmount;
        recipient.tokenAddress = tokenAddress;
        recipient.tokenPrice = tokenPrice;
        recipient.maxAllocationPerUser = maxAllocationPerUser;

        // update the review data
        review.reviewStartDate = block.timestamp;
        review.reviewEndDate = review.reviewStartDate + reviewPeriod;

        // todo: add governance reward and claim

        emit RecipientRegistered(
            recipientId, recipientAddress, metadata, offeringAmount, offeringPeriod, tokenAddress, maxAllocationPerUser
        );
    }

    function _allocate(bytes memory _data, address _sender) internal override {
        address recipientId;
        uint256 amount; // in pool token

        // decode data custom to this strategy
        (recipientId, amount) = abi.decode(_data, (address, uint256));

        // If the recipient is not accepted this will revert
        if (_getRecipientStatus(recipientId) != Status.Accepted || !_isRecipientAllocationActive(recipientId)) {
            revert RECIPIENT_ERROR(recipientId);
        }

        // If the allocator is not valid this will revert
        if (!_isValidAllocator(_sender)) {
            revert INVALID();
        }

        // Get the recipient
        Recipient storage recipient = recipients[recipientId];
        // Get the allocations
        Allocations storage allocation = allocations[recipientId];

        uint256 userTotalAmount = allocation.userAllocations[_sender] + amount;

        // If the amount is zero this will revert
        if (amount == 0 || userTotalAmount > recipient.maxAllocationPerUser) {
            revert INVALID();
        }

        // Update the allocations data
        allocation.totalAllocations += amount;
        allocation.userAllocations[_sender] += amount;

        _transferAmountFrom(poolToken, TransferData({from: _sender, to: address(this), amount: amount}));

        // Emit the event
        emit Allocated(recipientId, amount, poolToken, _sender);
    }

    function _distribute(address[] memory _recipientIds, bytes memory, address _sender) internal override {
        // todo: implement "claiming" for recipients
        // get recipient and allocation
        uint256 length = _recipientIds.length;

        for (uint256 i = 0; i < length; i++) {
            Recipient storage recipient = recipients[_recipientIds[i]];
            Allocations storage allocation = allocations[_recipientIds[i]];
            // todo: implement "claiming" for recipients

            // calculate cut

        }
    }

    // todo: implement withdraw when rejected

    
    function reviewRecipients(address[] memory recipientIds, bool[] memory approvals) external {
        uint256 length = recipientIds.length;
        for (uint256 i = 0; i < length; i++) {
            _reviewRecipient(recipientIds[i], approvals[i]);
        }
    }

    /// @notice Returns the payout summary for the accepted recipient.
    /// @dev This will revert by default.
    function _getPayout(address, bytes memory) internal pure override returns (PayoutSummary memory) {
        revert();
    }

    function _reviewRecipient(address recipientId, bool approve) internal onlyPoolManager(msg.sender) {
        Review storage review = reviews[recipientId];

        if (_getRecipientStatus(recipientId) != Status.Pending) {
            revert RECIPIENT_ERROR(recipientId);
        }

        if (review.reviewed[msg.sender] > 0) {
            revert REVIEWED_ALREADY();
        }

        // the governance token amount will be used in future
        review.reviewed[msg.sender] = 1;
        review.totalReviews++;

        if (approve) {
            review.approvals++;
        } else {
            review.rejections++;
        }
    }

    // ==============================
    // ========= Internal ===========
    // ==============================

    /// @notice Check if sender is profile owner or member.
    /// @param _anchor Anchor of the profile
    /// @param _sender The sender of the transaction
    /// @return 'true' if the '_sender' is a profile member, otherwise 'false'
    function _isProfileMember(address _anchor, address _sender) internal view virtual returns (bool) {
        IRegistry.Profile memory profile = registry.getProfileByAnchor(_anchor);
        return registry.isOwnerOrMemberOfProfile(profile.id, _sender);
    }

    /// @notice Checks if address is eligible allocator.
    /// @return True, if address is pool manager, otherwise false.
    function _isValidAllocator(address allocator) internal view override returns (bool) {
        return allo.isPoolManager(poolId, allocator);
    }

    // ===============================
    // =========== Setters ===========
    // ===============================

    /// @notice Sets the registry address
    /// @param _registry The address of the registry
    function setRegistry(IRegistry _registry) external onlyPoolManager(msg.sender) {
        registry = _registry;

        emit RegistrySet(msg.sender, address(_registry));
    }

    /// @notice Sets the review threshold
    /// @param _reviewThreshold The review threshold
    function setReviewThreshold(uint256 _reviewThreshold) external onlyPoolManager(msg.sender) {
        reviewThreshold = _reviewThreshold;

        emit ReviewThresholdSet(msg.sender, _reviewThreshold);
    }

    /// @notice Sets the number of reviews needed
    /// @param _reviewsNeeded The number of reviews needed
    function setReviewsNeeded(uint64 _reviewsNeeded) external onlyPoolManager(msg.sender) {
        reviewsNeeded = _reviewsNeeded;

        emit ReviewsNeededSet(msg.sender, _reviewsNeeded);
    }

    /// @notice Sets the review period
    /// @param _reviewPeriod The review period
    function setReviewPeriod(uint64 _reviewPeriod) external onlyPoolManager(msg.sender) {
        reviewPeriod = _reviewPeriod;

        emit ReviewPeriodSet(msg.sender, _reviewPeriod);
    }

    /// @notice Sets the max offering period
    /// @param _maxOfferingPeriod The max offering period
    function setMaxOfferingPeriod(uint64 _maxOfferingPeriod) external onlyPoolManager(msg.sender) {
        maxOfferingPeriod = _maxOfferingPeriod;

        emit MaxOfferingPeriodSet(msg.sender, _maxOfferingPeriod);
    }

    /// @notice Get recipient status
    /// @dev This will return the 'Status' of the recipient, the 'Status' is used at the strategy
    ///      level and is different from the 'Status' which is used at the protocol level
    /// @param _recipientId ID of the recipient
    /// @return Status of the recipient
    function _getRecipientStatus(address _recipientId) internal view override returns (Status) {
        Review storage review = reviews[_recipientId];

        if (review.reviewStartDate == 0) {
            return Status.None;
        }
        if (review.reviewEndDate > block.timestamp) {
            return Status.Pending;
        }
        uint256 totalReviews = review.totalReviews;
        uint256 approvalPercentage = (review.approvals * 1e18) / totalReviews;

        if (reviewsNeeded >= totalReviews && approvalPercentage >= reviewThreshold) {
            return Status.Accepted;
        } else {
            return Status.Rejected;
        }
    }

    function _isRecipientAllocationActive(address _recipientId) internal view returns (bool) {
        Recipient storage recipient = recipients[_recipientId];
        return recipient.offeringStartDate <= block.timestamp && recipient.offeringEndDate >= block.timestamp;
    }

    /// @notice Contract should be able to receive NATIVE
    receive() external payable {}
}
