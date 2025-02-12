// admin access control to users
module core::permissions {
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;
    use aptos_framework::resource_account;
    use aptos_framework::account::{Self, SignerCapability};

    use std::signer;

    use core::error;

    friend core::user;

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Permission has key {
        signer_cap: SignerCapability,
        admin_addr: address
    }

    inline fun get_permission(): &mut Permission acquires Permission {
        borrow_global_mut<Permission>(@core)
    }

    fun init_module(admin: &signer) {
        create_resource_signer(admin, @publisher)
    }

    #[test_only]
    public fun setup_for_test(resource_account: &signer) {
        init_module(resource_account);
    }

    public fun create_resource_signer(
        resource_account: &signer, admin_addr: address
    ) {
        if (exists<Permission>(signer::address_of(resource_account))) {
            return ()
        };

        let resource_signer_cap =
            resource_account::retrieve_resource_account_cap(resource_account, admin_addr);
        move_to(
            resource_account,
            Permission { signer_cap: resource_signer_cap, admin_addr: admin_addr }
        );
        coin::register<aptos_coin::AptosCoin>(resource_account);
    }

    #[view]
    public fun get_admin_address(): address acquires Permission {
        let module_permission = borrow_global<Permission>(@core);

        module_permission.admin_addr
    }

    public fun get_signer(admin: &signer): signer acquires Permission {
        assert_permission(admin);
        let module_permission = get_permission();
        account::create_signer_with_capability(&module_permission.signer_cap)
    }

    public(friend) fun get_signer_internal(): signer acquires Permission {
        let module_permission = get_permission();
        account::create_signer_with_capability(&module_permission.signer_cap)
    }

    public fun transfer_ownership(admin: &signer, asignee: address) acquires Permission {
        assert_permission(admin);
        let module_permission = get_permission();
        module_permission.admin_addr = asignee;
    }

    public fun assert_permission(caller: &signer) acquires Permission {
        let caller_address = signer::address_of(caller);
        let module_permission = get_permission();
        assert!(
            module_permission.admin_addr == caller_address,
            error::not_authorized()
        );
    }

}