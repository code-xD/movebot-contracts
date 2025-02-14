#[test_only]
module token::fa_wallet_test {
    use aptos_framework::primary_fungible_store;

    use std::signer;
    use std::string::{utf8, String};

    use core::user;
    use core::wallet;
    use core::test_utils;
    use core::permissions_test;

    use token::fa_wallet;
    use token::repository;
    
    #[test(resource_account = @core, admin = @publisher, aaron = @0xCAFE)]
    fun test_verified_fa_basic_flow(resource_account: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, resource_account);
        repository::setup_for_test(admin);

        let token_metadata = test_utils::create_and_mint_test_token(aaron, 1000);
        repository::upsert_verified_fa_metadata(admin, token_metadata);

        let symbol: String = utf8(b"TST");
        let tuser_id: String = utf8(b"First User");

        let user_signer = &user::get_user_signer(admin, tuser_id);

        wallet::assert_wallet_has_sufficient_fa_balance(tuser_id, token_metadata, 0);

        fa_wallet::fund_verified_fa_for_wallet_by_twitter_user_id(aaron, tuser_id, symbol, 100);
        wallet::assert_wallet_has_sufficient_fa_balance(tuser_id, token_metadata, 100);
        assert!(primary_fungible_store::balance(signer::address_of(user_signer), token_metadata) == 100, 1);
        assert!(primary_fungible_store::balance(signer::address_of(aaron), token_metadata) == 900, 2);

        fa_wallet::fund_verified_fa_for_wallet_by_user_address(aaron, signer::address_of(user_signer), symbol, 100);
        wallet::assert_wallet_has_sufficient_fa_balance(tuser_id, token_metadata, 200);
        assert!(primary_fungible_store::balance(signer::address_of(user_signer), token_metadata) == 200, 3);
        assert!(primary_fungible_store::balance(signer::address_of(aaron), token_metadata) == 800, 4);
    }
}