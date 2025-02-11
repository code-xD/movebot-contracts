#[test_only]
module core::permissions_test {
    use aptos_framework::aptos_coin;
    use aptos_framework::aptos_account;
    use aptos_framework::resource_account;

    use core::permissions;

    use std::signer;
    use std::vector;

    fun setup_for_test(admin: &signer, resource_account: &signer) {
        aptos_coin::ensure_initialized_with_apt_fa_metadata_for_test();
        aptos_account::create_account(signer::address_of(admin));
        resource_account::create_resource_account(
            admin, vector::empty(), vector::empty()
        );

        permissions::setup_for_test(resource_account)
    }

    #[test(resource_account = @core, admin = @publisher)]
    fun test_permission(resource_account: &signer, admin: &signer) {
        setup_for_test(admin, resource_account);

        permissions::assert_permission(admin);
    }

    #[test(resource_account = @core, admin = @publisher, aaron = @0xFACE)]
    #[expected_failure(abort_code = 0x52001, location = core::permissions)]
    fun test_permission_denied(
        resource_account: &signer, admin: &signer, aaron: &signer
    ) {
        setup_for_test(admin, resource_account);

        permissions::assert_permission(aaron);
    }

    #[test(resource_account = @core, admin = @publisher, aaron = @0xFACE)]
    fun test_permission_transfer(
        resource_account: &signer, admin: &signer, aaron: &signer
    ) {
        setup_for_test(admin, resource_account);

        permissions::assert_permission(admin);
        permissions::transfer_ownership(admin, signer::address_of(aaron));
        permissions::assert_permission(aaron);
    }

}
