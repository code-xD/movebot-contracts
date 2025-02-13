#[test_only]
module token::repository_test {
    use std::string::{utf8, String};

    use core::user;
    use core::permissions_test;

    use token::repository;
    use token::manager_test;

    #[test(core = @core, admin = @publisher)]
    fun test_basic_flow(core: &signer, admin: &signer) {
        permissions_test::setup_for_test(admin, core);
        repository::setup_for_test(admin);

        let tuser_id: String = utf8(b"First User");
        let user_signer = &user::get_user_signer(admin, tuser_id);
        let token_metadata = manager_test::create_test_token(user_signer, 0);

        repository::upsert_verified_fa_metadata(admin, token_metadata);
        
        assert!(
            repository::get_metadata_for_verified_fa(utf8(b"TST")) == token_metadata,
            1
        );
    }

    #[test(core = @core, admin = @publisher)]
    #[expected_failure(abort_code = 0x65005, location = token::repository)]
    fun test_removal_flow(core: &signer, admin: &signer) {
        permissions_test::setup_for_test(admin, core);
        repository::setup_for_test(admin);

        let symbol: String = utf8(b"TST");
        let tuser_id: String = utf8(b"First User");
        let user_signer = &user::get_user_signer(admin, tuser_id);
        let token_metadata = manager_test::create_test_token(user_signer, 0);

        repository::upsert_verified_fa_metadata(admin, token_metadata);
        
        assert!(
            repository::get_metadata_for_verified_fa(symbol) == token_metadata,
            1
        );

        repository::remove_verified_fa_metadata(admin, symbol);

        assert!(
            repository::get_metadata_for_verified_fa(symbol) == token_metadata,
            2
        );
    }
}