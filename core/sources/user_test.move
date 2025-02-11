#[test_only]
module core::user_test {
    use std::signer;
    use std::string::{utf8, String};

    use core::user;
    use core::permissions_test;

    #[test(resource_account = @core, admin = @publisher)]
    fun test_basic_flow(resource_account: &signer, admin: &signer) {
        permissions_test::setup_for_test(admin, resource_account);

        let tuser_id: String = utf8(b"First User");

        user::create_user(admin, tuser_id);

        let user_signer = &user::get_user_signer(admin, tuser_id);
        let user_address = user::get_user_address(tuser_id);
        assert!(user_address == signer::address_of(user_signer), 2);

        assert!(user::check_valid_user_address(user_address), 3);
    }

    #[test(resource_account = @core, admin = @publisher)]
    #[expected_failure(abort_code = 0x51001, location = core::user)]
    fun test_user_account_not_registered(resource_account: &signer, admin: &signer) {
        permissions_test::setup_for_test(admin, resource_account);

        let tuser_id: String = utf8(b"First User");
        user::get_user_address(tuser_id);
    }

    #[test(resource_account = @core, admin = @publisher)]
    #[expected_failure(abort_code = 0x81002, location = core::user)]
    fun test_user_already_registered(resource_account: &signer, admin: &signer) {
        permissions_test::setup_for_test(admin, resource_account);

        let tuser_id: String = utf8(b"First User");
        user::create_user(admin, tuser_id);
        user::create_user(admin, tuser_id);
    }
}