# Decentralized IP Management Module 📄

The **Decentralized IP Management** module is a blockchain-based application designed to manage intellectual property (IP) rights using the Sui blockchain platform. This module allows users to securely and transparently manage IP ownership, create license agreements, handle disputes, and perform royalty payments, ensuring the traceability of IP transactions and resolutions.

## Struct Definitions

### `IntellectualProperty`
- **id**: Unique identifier for the intellectual property.
- **creator**: Address of the IP's creator (owner).
- **title**: Title of the IP.
- **ip_type**: Type of the IP (e.g., patent, trademark, copyright).
- **description**: Description of the IP.
- **is_registered**: Boolean indicating whether the IP is registered.

### `LicenseAgreement`
- **id**: Unique identifier for the license agreement.
- **ip_id**: Identifier of the associated intellectual property.
- **licensee**: Address of the licensee.
- **licensor**: Address of the licensor (IP owner).
- **terms**: Terms of the license agreement.
- **royalty_amount**: Amount of royalty to be paid.
- **is_active**: Boolean indicating whether the license agreement is active.

### `Dispute`
- **id**: Unique identifier for the dispute.
- **ip_id**: Identifier of the associated intellectual property.
- **claimant**: Address of the claimant.
- **respondent**: Address of the respondent.
- **details**: Details of the dispute.
- **is_resolved**: Boolean indicating whether the dispute is resolved.

## Events

- **IPRegistered**: Triggered when a new intellectual property is registered.
- **LicenseCreated**: Triggered when a new license agreement is created.
- **RoyaltyPaid**: Triggered when a royalty payment is made.
- **DisputeCreated**: Triggered when a new dispute is created.
- **DisputeResolved**: Triggered when a dispute is resolved.
- **IPTransferred**: Triggered when an intellectual property is transferred.
- **IPUpdated**: Triggered when an intellectual property is updated.
- **LicenseUpdated**: Triggered when a license agreement is updated.

## Public Entry Functions

- **register_ip**: Registers a new intellectual property with the given title, type, and description.
- **create_license**: Creates a new license agreement for the specified IP, licensee, terms, and royalty amount.
- **pay_royalties**: Pays royalties for a license agreement.
- **create_dispute**: Creates a new dispute for the specified IP and respondent.
- **resolve_dispute**: Resolves a dispute with the provided resolution details.
- **transfer_ip**: Transfers ownership of an intellectual property to a new owner.
- **update_ip_description**: Updates the description of an intellectual property.
- **update_license_terms**: Updates the terms of a license agreement.
- **view_ip_details**: Retrieves details of an intellectual property.
- **view_license_details**: Retrieves details of a license agreement.
- **view_dispute_details**: Retrieves details of a dispute.

## Usage Guidelines

### SUI CLI Interaction
- Use the SUI CLI to call functions like `register_ip`, `create_license`, and `pay_royalties`.
- Provide the required transaction context and function arguments as necessary.
- Monitor transaction logs to verify events and state changes.

### Web Interface Development (Optional)
- Build a web application to interact with this module, providing a user-friendly interface for IP creators and licensees.
- Implement features to handle transactions and display IP information securely.

## Conclusion

The Decentralized IP Management module empowers creators and licensees to manage and exchange intellectual properties with transparency and security. It facilitates efficient handling of IP registration, licensing, dispute resolution, and royalty payments, fostering a robust ecosystem for intellectual property rights.

