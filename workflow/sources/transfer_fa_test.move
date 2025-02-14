#[test_only]
module workflow::transfer_fa_test {
    use aptos_framework::primary_fungible_store;

    use std::signer;
    use std::string::{utf8, String};

    use core::user;
    use core::permissions_test;

    use token::manager;
    use token::repository;

    use workflow::transfer_fa;
    use workflow::manage_token;

    #[test(core = @core, admin = @publisher)]
    fun test_basic_flow(core: &signer, admin: &signer) {
        permissions_test::setup_for_test(admin, core);
        repository::setup_for_test(admin);

        let tuser_id: String = utf8(b"First User");
        let tuser_id2: String = utf8(b"Second User");

        let symbol: String = utf8(b"TST");
        let name: String = utf8(b"Test Token");

        let icon_uri: String = utf8(b"http://test.com/fav.ico");
        let project_uri: String = utf8(b"http://test.com");
        let supply: u128 = 1000;

        let user_signer = &user::get_user_signer(admin, tuser_id);
        let user_signer2 = &user::get_user_signer(admin, tuser_id2);

        manage_token::create_token(admin, tuser_id, symbol, name, supply, icon_uri, project_uri);

        let token_metadata = manager::get_metadata(signer::address_of(user_signer), symbol);
        repository::upsert_verified_fa_metadata(admin, token_metadata);

        assert!(primary_fungible_store::balance(signer::address_of(user_signer), token_metadata) == 1000, 1);
        transfer_fa::transfer_token_by_tuser_id_and_symbol(admin, tuser_id, tuser_id, symbol, signer::address_of(user_signer2), 100);
        assert!(primary_fungible_store::balance(signer::address_of(user_signer), token_metadata) == 900, 2);
        assert!(primary_fungible_store::balance(signer::address_of(user_signer2), token_metadata) == 100, 3);

        transfer_fa::transfer_token_by_token_address(admin, tuser_id, token_metadata, signer::address_of(user_signer2), 100);
        assert!(primary_fungible_store::balance(signer::address_of(user_signer), token_metadata) == 800, 4);
        assert!(primary_fungible_store::balance(signer::address_of(user_signer2), token_metadata) == 200, 5);

        transfer_fa::transfer_token_by_verified_symbol(admin, tuser_id, symbol, signer::address_of(user_signer2), 100);
        assert!(primary_fungible_store::balance(signer::address_of(user_signer), token_metadata) == 700, 6);
        assert!(primary_fungible_store::balance(signer::address_of(user_signer2), token_metadata) == 300, 7);
    }

}