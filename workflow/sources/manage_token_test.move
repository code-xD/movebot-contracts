#[test_only]
module workflow::manage_token_test {
    use aptos_framework::object;
    use aptos_framework::primary_fungible_store;

    use std::signer;
    use std::string::{utf8, String};

    use core::user;
    use core::permissions_test;

    use token::manager;

    use workflow::manage_token;

    #[test(core = @core, admin = @publisher, aaron = @0xCAFE)]
    fun test_basic_flow(core: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, core);

        let tuser_id: String = utf8(b"First User");

        let symbol: String = utf8(b"TST");
        let name: String = utf8(b"Test Token");

        let icon_uri: String = utf8(b"http://test.com/fav.ico");
        let project_uri: String = utf8(b"http://test.com");
        let supply: u128 = 1000;

        let user_signer = &user::get_user_signer(admin, tuser_id);

        manage_token::create_token(admin, tuser_id, symbol, name, supply, icon_uri, project_uri);

        let token_metadata = manager::get_metadata(signer::address_of(user_signer), symbol);
        assert!(object::is_owner(token_metadata, signer::address_of(user_signer)), 1);
        assert!(primary_fungible_store::balance(signer::address_of(user_signer), token_metadata) == 1000, 2);
        
        manage_token::transfer_token_ownership_by_symbol(admin, tuser_id, symbol, signer::address_of(aaron));
        assert!(object::is_owner(token_metadata, signer::address_of(aaron)), 3);

        let symbol: String = utf8(b"TST1");
        manage_token::create_token(admin, tuser_id, symbol, name, supply, icon_uri, project_uri);

        let token_metadata = manager::get_metadata(signer::address_of(user_signer), symbol);
        assert!(object::is_owner(token_metadata, signer::address_of(user_signer)), 4);
        assert!(primary_fungible_store::balance(signer::address_of(user_signer), token_metadata) == 1000, 5);
        
        manage_token::transfer_token_ownership_by_address(admin, tuser_id, token_metadata, signer::address_of(aaron));
        assert!(object::is_owner(token_metadata, signer::address_of(aaron)), 6);
    }

}