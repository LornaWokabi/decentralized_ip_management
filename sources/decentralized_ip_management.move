module decentralized_ip_management::ip_management {
    use sui::coin::{Coin, Self};
    use sui::sui::SUI;
    use sui::tx_context::{TxContext, sender};
    use sui::object::{Self, UID, ID};
    use sui::transfer::{public_transfer};
    use sui::event;

    // Errors Definitions
    const UNAUTHORIZED_ACCESS: u64 = 1;
    const LICENSE_NOT_FOUND: u64 = 2;
    const INSUFFICIENT_FUNDS: u64 = 3;
    const DISPUTE_NOT_FOUND: u64 = 4;

    // Struct representing an intellectual property
    struct IntellectualProperty has key, store {
        id: UID,
        creator: address,
        title: vector<u8>,
        ip_type: vector<u8>,
        description: vector<u8>,
        is_registered: bool,
    }

    // Struct representing a license agreement
    struct LicenseAgreement has key, store {
        id: UID,
        ip_id: u64,
        licensee: address,
        licensor: address,
        terms: vector<u8>,
        royalty_amount: u64,
        is_active: bool,
    }

    // Struct representing a dispute
    struct Dispute has key, store {
        id: UID,
        ip_id: u64,
        claimant: address,
        respondent: address,
        details: vector<u8>,
        is_resolved: bool,
    }

    // Events
    struct IPRegistered has copy, drop {
        id: ID,
        creator: address,
        title: vector<u8>,
    }
    struct LicenseCreated has copy, drop {
        id: ID,
        ip_id: u64,
        licensee: address,
        licensor: address,
    }
    struct RoyaltyPaid has copy, drop {
        id: ID,
        ip_id: u64,
        amount: u64,
    }
    struct DisputeCreated has copy, drop {
        id: ID,
        ip_id: u64,
        claimant: address,
    }
    struct DisputeResolved has copy, drop {
        id: ID,
        ip_id: u64,
        resolution: vector<u8>,
    }
    struct IPTransferred has copy, drop {
        id: ID,
        from: address,
        to: address,
    }
    struct IPUpdated has copy, drop {
        id: ID,
        updated_by: address,
        new_description: vector<u8>,
    }
    struct LicenseUpdated has copy, drop {
        id: ID,
        updated_by: address,
        new_terms: vector<u8>,
    }

    // Register a new intellectual property
    public fun register_ip(title: vector<u8>, ip_type: vector<u8>, description: vector<u8>, ctx: &mut TxContext): IntellectualProperty {
        let ip_id = object::new(ctx);
        let ip = IntellectualProperty {
            id: ip_id,
            creator: sender(ctx),
            title,
            ip_type,
            description,
            is_registered: true,
        };
        event::emit(IPRegistered {
            id: object::uid_to_inner(&ip.id),
            creator: ip.creator,
            title: ip.title,
        });
        ip
    }

    // Create a license agreement
    public fun create_license(ip_id: u64, licensee: address, terms: vector<u8>, royalty_amount: u64, ctx: &mut TxContext): LicenseAgreement {
        let licensor = sender(ctx);
        let license_id = object::new(ctx);
        let license = LicenseAgreement {
            id: license_id,
            ip_id,
            licensee,
            licensor,
            terms,
            royalty_amount,
            is_active: true,
        };
        event::emit(LicenseCreated {
            id: object::uid_to_inner(&license.id),
            ip_id: license.ip_id,
            licensee: license.licensee,
            licensor: licensor,
        });
        license
    }

    // Pay royalties
    public fun pay_royalties(license: &mut LicenseAgreement, payment: Coin<SUI>) {
        assert!(license.is_active, LICENSE_NOT_FOUND);
        assert!(coin::value(&payment) >= license.royalty_amount, INSUFFICIENT_FUNDS);

        let licensor = license.licensor;
        // Transfer payment to the licensor
        public_transfer(payment, licensor);

        // Emit royalty payment event
        event::emit(RoyaltyPaid {
            id: object::uid_to_inner(&license.id),
            ip_id: license.ip_id,
            amount: license.royalty_amount,
        });
    }

    // Create a dispute
    public fun create_dispute(ip_id: u64, respondent: address, details: vector<u8>, ctx: &mut TxContext): Dispute {
        let claimant = sender(ctx);
        let dispute_id = object::new(ctx);
        let dispute = Dispute {
            id: dispute_id,
            ip_id,
            claimant,
            respondent,
            details,
            is_resolved: false,
        };
        event::emit(DisputeCreated {
            id: object::uid_to_inner(&dispute.id),
            ip_id: dispute.ip_id,
            claimant: dispute.claimant,
        });
        dispute
    }

    // Resolve a dispute
    public fun resolve_dispute(dispute: &mut Dispute, resolution: vector<u8>, ctx: &mut TxContext) {
        assert!(sender(ctx) == dispute.claimant || sender(ctx) == dispute.respondent, UNAUTHORIZED_ACCESS);
        assert!(!dispute.is_resolved, DISPUTE_NOT_FOUND);

        dispute.is_resolved = true;

        // Emit dispute resolution event
        event::emit(DisputeResolved {
            id: object::uid_to_inner(&dispute.id),
            ip_id: dispute.ip_id,
            resolution,
        });
    }

    // Transfer IP ownership
    public fun transfer_ip(ip: &mut IntellectualProperty, new_owner: address, ctx: &mut TxContext) {
        assert!(sender(ctx) == ip.creator, UNAUTHORIZED_ACCESS);
        let old_owner = ip.creator;
        ip.creator = new_owner;

        // Emit IP transfer event
        event::emit(IPTransferred {
            id: object::uid_to_inner(&ip.id),
            from: old_owner,
            to: new_owner,
        });
    }

    // Update IP description
    public fun update_ip_description(ip: &mut IntellectualProperty, new_description: vector<u8>, ctx: &mut TxContext) {
        assert!(sender(ctx) == ip.creator, UNAUTHORIZED_ACCESS);
        ip.description = new_description;

        // Emit IP update event
        event::emit(IPUpdated {
            id: object::uid_to_inner(&ip.id),
            updated_by: ip.creator,
            new_description,
        });
    }

    // Update license terms
    public fun update_license_terms(license: &mut LicenseAgreement, new_terms: vector<u8>, ctx: &mut TxContext) {
        assert!(sender(ctx) == license.licensor, UNAUTHORIZED_ACCESS);
        license.terms = new_terms;

        // Emit license update event
        event::emit(LicenseUpdated {
            id: object::uid_to_inner(&license.id),
            updated_by: license.licensor,
            new_terms,
        });
    }

    // View IP details
    public fun view_ip_details(ip: &IntellectualProperty): (vector<u8>, address, vector<u8>, vector<u8>, bool) {
        (ip.title, ip.creator, ip.ip_type, ip.description, ip.is_registered)
    }

    // View license details
    public fun view_license_details(license: &LicenseAgreement): (u64, address, address, vector<u8>, u64, bool) {
        (license.ip_id, license.licensee, license.licensor, license.terms, license.royalty_amount, license.is_active)
    }

    // View dispute details
    public fun view_dispute_details(dispute: &Dispute): (u64, address, address, vector<u8>, bool) {
        (dispute.ip_id, dispute.claimant, dispute.respondent, dispute.details, dispute.is_resolved)
    }

    // Additional functionality

    // Function to list all intellectual properties
    public fun list_all_ips(ctx: &TxContext): vector<IntellectualProperty> {
        let objects = object::list_all();
        let mut ips = vector<IntellectualProperty>::empty();
        for obj in objects {
            if (object::type(obj) == type_of<IntellectualProperty>()) {
                let ip: IntellectualProperty = object::read(obj);
                ips.push_back(ip);
            }
        }
        ips
    }

    // Function to list all licenses
    public fun list_all_licenses(ctx: &TxContext): vector<LicenseAgreement> {
        let objects = object::list_all();
        let mut licenses = vector<LicenseAgreement>::empty();
        for obj in objects {
            if (object::type(obj) == type_of<LicenseAgreement>()) {
                let license: LicenseAgreement = object::read(obj);
                licenses.push_back(license);
            }
        }
        licenses
    }

    // Function to list all disputes
    public fun list_all_disputes(ctx: &TxContext): vector<Dispute> {
        let objects = object::list_all();
        let mut disputes = vector<Dispute>::empty();
        for obj in objects {
            if (object::type(obj) == type_of<Dispute>()) {
                let dispute: Dispute = object::read(obj);
                disputes.push_back(dispute);
            }
        }
        disputes
    }

    // Function to fetch all IPs created by a user
    public fun get_user_ips(user: address, ctx: &TxContext): vector<IntellectualProperty> {
        let objects = object::list(user);
        let mut ips = vector<IntellectualProperty>::empty();
        for obj in objects {
            if (object::type(obj) == type_of<IntellectualProperty>()) {
                let ip: IntellectualProperty = object::read(obj);
                ips.push_back(ip);
            }
        }
        ips
    }

    // Function to fetch all licenses owned by a user
    public fun get_user_licenses(user: address, ctx: &TxContext): vector<LicenseAgreement> {
        let objects = object::list(user);
        let mut licenses = vector<LicenseAgreement>::empty();
        for obj in objects {
            if (object::type(obj) == type_of<LicenseAgreement>()) {
                let license: LicenseAgreement = object::read(obj);
                licenses.push_back(license);
            }
        }
        licenses
    }
}
