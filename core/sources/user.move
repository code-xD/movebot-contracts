// resource account creation and management for bot users
module core::user {
    use aptos_framework::coin;
    use aptos_framework::account;
    use aptos_framework::aptos_coin;

    use std::signer;
    use std::string::{String, bytes};

    use core::permissions;
    use core::error;

    struct UserAuth has key {
        signer_cap: account::SignerCapability,
        tuser_id: String
    }

    fun is_user_registered(admin: &signer, tuser_id: String): (address, bool) {
        let admin_address = signer::address_of(admin);
        let user_address = account::create_resource_address(&admin_address, *bytes(&tuser_id));

        (user_address, exists<UserAuth>(user_address))
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

    public fun get_user_signer(caller: &signer, tuser_id: String): signer acquires UserAuth {
        let admin = &permissions::get_signer(caller);
        let (user_address, user_exists) = is_user_registered(admin, tuser_id);
        assert!(user_exists, error::user_not_registered());

        let user_auth = borrow_global<UserAuth>(user_address);
        account::create_signer_with_capability(&user_auth.signer_cap)
    }

    public entry fun create_user(caller: &signer, tuser_id: String) {
        let admin = &permissions::get_signer(caller);

        let (_, user_exists) = is_user_registered(admin, tuser_id);
        assert!(!user_exists, error::user_already_registered());

        let (user_signer, signer_cap) = account::create_resource_account(admin, *bytes(&tuser_id));

        move_to<UserAuth>(&user_signer, UserAuth{
            signer_cap,
            tuser_id
        });

        coin::register<aptos_coin::AptosCoin>(&user_signer);
    }

    // transfer_ownership (revoke bot ownership of SignerCap and transfer to new user)

    // get_user_signer_unauthorized
}
