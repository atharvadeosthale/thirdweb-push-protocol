// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/ERC721Drop.sol";
import "@thirdweb-dev/contracts/openzeppelin-presets/security/ReentrancyGuard.sol";
import "@thirdweb-dev/contracts/extension/PermissionsEnumerable.sol";
import "@thirdweb-dev/contracts/extension/Drop.sol";
import "@thirdweb-dev/contracts/extension/interface/IDrop.sol";

struct AllowlistProof {
    bytes32[] proof;
    uint256 quantityLimitPerWallet;
    uint256 pricePerToken;
    address currency;
}
// PUSH Comm Contract Interface
interface IPUSHCommInterface {
    function sendNotification(address _channel, address _recipient, bytes calldata _identity) external;
}

contract Contract is PermissionsEnumerable, ERC721Drop {
    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    constructor(
        string memory _name,
        string memory _symbol,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        address _primarySaleRecipient
    )
        ERC721Drop(
            _name,
            _symbol,
            _royaltyRecipient,
            _royaltyBps,
            _primarySaleRecipient
        )
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(TRANSFER_ROLE, msg.sender);
    }

    function _afterClaim(
        address _receiver,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        AllowlistProof calldata _allowlistProof,
        bytes memory _data
    ) internal override {
        // Apply PUSH protocol
        IPUSHCommInterface(address(0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa)).sendNotification(
            address(0x1aEe598A33B002d3857bAF8663651924d174F56c), // from channel - recommended to set channel via dApp and put it's value -> then once contract is deployed, go back and add the contract address as delegate for your channel
            address(this), // to recipient, put address(this) in case you want Broadcast or Subset. For Targetted put the address to which you want to send
            bytes(
                string(
                    // We are passing identity here: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                    abi.encodePacked(
                        "0", // this is notification identity: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                        "+", // segregator
                        "1", // this is payload type: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/payload (1, 3 or 4) = (Broadcast, targetted or subset)
                        "+", // segregator
                        "Drop Claimed", // this is notificaiton title
                        "+", // segregator
                        "You've successfully claimed the drop!" // notification body
                    )
                )
            )
        );
    }

}