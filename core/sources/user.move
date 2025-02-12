// resource account creation and management for bot users
module core::user {
    use aptos_framework::coin;
    use aptos_framework::account;
    use aptos_framework::aptos_coin;

    use std::signer;
    use std::string::{String, bytes};

    use core::error;
    use core::event;
    use core::permissions;
    

    struct UserAuth has key {
        signer_cap: account::SignerCapability,
        tuser_id: String
    }

    const USER_MODULE: vector<u8> = b"user";
    const USER_REGISTERED_ACTION: vector<u8> = b"USER_REGISTERED";

    #[event]
    struct UserRegisteredEvent has drop, store {
        tuser_id: String,
        user_address: address
    }

    fun is_user_registered(admin: &signer, tuser_id: String): (address, bool) {
        let admin_address = signer::address_of(admin);
        let user_address = account::create_resource_address(&admin_address, *bytes(&tuser_id));

        (user_address, exists<UserAuth>(user_address))
    }

    inline fun get_user_auth(user_signer: &signer): &UserAuth acquires UserAuth {
        borrow_global<UserAuth>(signer::address_of(user_signer))
    }

    #[test_only]
    public fun is_user_registered_event_emitted(caller: &signer, tuser_id: String, user_address: address): bool {
        event::has_core_event_emitted(caller, USER_MODULE, USER_REGISTERED_ACTION, UserRegisteredEvent {
            tuser_id,
            user_address,
        })
    }

    #[test_only]
    public fun is_workflow_event_emitted<T: drop + store>(caller: &signer, user_signer: &signer, tweet_id: String, 
    scope: vector<u8>, action: vector<u8>, metadata: T): bool acquires UserAuth{
        let user_auth = get_user_auth(user_signer);
        event::has_workflow_event_emitted(
            caller,
            signer::address_of(user_signer),
            user_auth.tuser_id,
            tweet_id,
            scope,
            action,
            metadata
        )
    }

    #[view]
    public fun check_valid_user_address(user_address: address): bool {
        exists<UserAuth>(user_address)
    }

    #[view]
    public fun get_user_address(tuser_id: String): address {
        let user_address = account::create_resource_address(&@core, *bytes(&tuser_id));

        if (!check_valid_user_address(user_address)) {
            abort error::user_not_registered()
        };

        user_address
    }

    public fun emit_workflow_event<T: drop + store>(caller: &signer, user_signer: &signer, tweet_id: String, 
    scope: vector<u8>, action: vector<u8>, metadata: T) acquires UserAuth {
        let user_auth = get_user_auth(user_signer);
        event::emit_workflow_event(
            caller,
            signer::address_of(user_signer),
            user_auth.tuser_id,
            tweet_id,
            scope,
            action,
            metadata
        );
    }

    public fun get_user_signer(caller: &signer, tuser_id: String): signer acquires UserAuth {
        let admin = &permissions::get_signer_internal();
        let (user_address, user_exists) = is_user_registered(admin, tuser_id);

        if (!user_exists) create_user(caller, tuser_id);

        let user_auth = borrow_global<UserAuth>(user_address);
        account::create_signer_with_capability(&user_auth.signer_cap)
    }

    public entry fun create_user(caller: &signer, tuser_id: String) {
        let admin = &permissions::get_signer_internal();

        let (_, user_exists) = is_user_registered(admin, tuser_id);
        assert!(!user_exists, error::user_already_registered());

        let (user_signer, signer_cap) = account::create_resource_account(admin, *bytes(&tuser_id));

        move_to<UserAuth>(&user_signer, UserAuth{
            signer_cap,
            tuser_id
        });

        coin::register<aptos_coin::AptosCoin>(&user_signer);

        event::emit_core_event(caller, USER_MODULE, USER_REGISTERED_ACTION, UserRegisteredEvent{
            tuser_id,
            user_address: signer::address_of(&user_signer),
        });
    }

    // transfer_ownership (revoke bot ownership of SignerCap and transfer to new user)

    // get_user_signer_unauthorized
}
