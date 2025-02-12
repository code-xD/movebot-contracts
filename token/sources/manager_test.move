#[test_only]
module token::manager_test {
    use aptos_framework::object::{Self, Object};
    use aptos_framework::primary_fungible_store;
    use aptos_framework::fungible_asset::{Metadata};

    use std::signer;
    use std::string::{String, utf8};

    use core::user;
    use core::permissions_test;

    use token::manager;

    public fun create_test_token(creator: &signer, supply: u128): Object<Metadata> {
        let symbol: String = utf8(b"TST");
        let name: String = utf8(b"Test Token");

        let icon_uri: String = utf8(b"http://test.com/fav.ico");
        let project_uri: String = utf8(b"http://test.com");

        manager::create_token(creator, name, symbol, supply, icon_uri, project_uri)
    }

    #[test(core = @core, admin = @publisher, aaron = @0xCAFE)]
    fun test_basic_flow(core: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, core);

        let tuser_id: String = utf8(b"First User");
        let user_signer = &user::get_user_signer(admin, tuser_id);
        let token_metadata = create_test_token(user_signer, 1000);

        assert!(primary_fungible_store::balance(signer::address_of(user_signer), token_metadata) == 1000, 1);

        manager::transfer_token(user_signer, token_metadata, signer::address_of(aaron), 100);
        assert!(primary_fungible_store::balance(signer::address_of(user_signer), token_metadata) == 900, 2);
        assert!(primary_fungible_store::balance(signer::address_of(aaron), token_metadata) == 100, 3);

        assert!(object::is_owner(token_metadata, signer::address_of(user_signer)), 4);
        manager::transfer_token_ownership(user_signer, token_metadata, signer::address_of(aaron));
        assert!(object::is_owner(token_metadata, signer::address_of(aaron)), 5);
    }

    #[test(core = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x63002, location = token::manager)]
    fun test_invalid_user_address_for_token_create(core: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, core);

        create_test_token(aaron, 1000);
    }

    #[test(core = @core, admin = @publisher)]
    #[expected_failure(abort_code = 0x85001, location = token::manager)]
    fun test_object_already_exists_for_token_create(core: &signer, admin: &signer) {
        permissions_test::setup_for_test(admin, core);

        let tuser_id: String = utf8(b"First User");
        let user_signer = &user::get_user_signer(admin, tuser_id);
        create_test_token(user_signer, 1000);
        create_test_token(user_signer, 1000);
    }

    #[test(core = @core, admin = @publisher)]
    #[expected_failure(abort_code = 0x25002, location = token::manager)]
    fun test_max_supply_exceeded_for_token_create(core: &signer, admin: &signer) {
        permissions_test::setup_for_test(admin, core);

        let tuser_id: String = utf8(b"First User");
        let user_signer = &user::get_user_signer(admin, tuser_id);
        create_test_token(user_signer, 1_000_000_000_0000_0000);
    }

    #[test(core = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x63002, location = token::manager)]
    fun test_invalid_user_address_for_token_ownership_transfer(core: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, core);

        let tuser_id: String = utf8(b"First User");
        let user_signer = &user::get_user_signer(admin, tuser_id);
        let token_metadata = create_test_token(user_signer, 1000);

        manager::transfer_token_ownership(aaron, token_metadata, signer::address_of(aaron));
    }

    #[test(core = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x55004, location = token::manager)]
    fun test_not_token_owner_for_token_ownership_transfer(core: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, core);

        let tuser_id: String = utf8(b"First User");
        let tuser_id2: String = utf8(b"Second User");
        let user_signer = &user::get_user_signer(admin, tuser_id);
        let user_signer2 = &user::get_user_signer(admin, tuser_id2);
        let token_metadata = create_test_token(user_signer, 1000);

        manager::transfer_token_ownership(user_signer2, token_metadata, signer::address_of(aaron));
    }

    #[test(core = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x63002, location = token::manager)]
    fun test_invalid_user_address_for_token_transfer(core: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, core);

        let tuser_id: String = utf8(b"First User");
        let user_signer = &user::get_user_signer(admin, tuser_id);
        let token_metadata = create_test_token(user_signer, 1000);

        manager::transfer_token(aaron, token_metadata, signer::address_of(aaron), 1000);
    }

    #[test(core = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x13001, location = token::manager)]
    fun test_insufficient_balance_for_token_ownership_transfer(core: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, core);

        let tuser_id: String = utf8(b"First User");
        let user_signer = &user::get_user_signer(admin, tuser_id);
        let token_metadata = create_test_token(user_signer, 1000);

        manager::transfer_token(user_signer, token_metadata, signer::address_of(aaron), 2000);
    }
}