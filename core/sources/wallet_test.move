#[test_only]
module core::wallet_test {
    use aptos_framework::coin;
    use aptos_framework::account;
    use aptos_framework::aptos_coin;
    use aptos_framework::primary_fungible_store;

    use std::signer;
    use std::string::{utf8, bytes, String};

    use core::user;
    use core::wallet;
    use core::test_utils;
    use core::permissions_test;

    #[test(aptos_framework = @0x1, resource_account = @core, admin = @publisher, aaron = @0xCAFE)]
    fun test_move_basic_flow(aptos_framework: &signer, resource_account: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, resource_account);
        test_utils::setup_account_and_fund_move(aptos_framework, aaron, 1000);

        let tuser_id: String = utf8(b"First User");

        let user_signer = &user::get_user_signer(admin, tuser_id);

        wallet::assert_wallet_has_sufficient_move_balance(tuser_id, 0);

        wallet::fund_move_for_wallet_by_twitter_user_id(aaron, tuser_id, 100);
        assert!(wallet::is_wallet_topup_by_tuser_id_event_emitted(aaron, tuser_id, 100), 1);
        wallet::assert_wallet_has_sufficient_move_balance(tuser_id, 100);
        assert!(coin::balance<aptos_coin::AptosCoin>(signer::address_of(user_signer)) == 100, 2);
        assert!(coin::balance<aptos_coin::AptosCoin>(signer::address_of(aaron)) == 900, 3);

        wallet::fund_move_for_wallet_by_user_address(aaron, signer::address_of(user_signer), 100);
        assert!(wallet::is_wallet_topup_by_user_address_event_emitted(aaron, signer::address_of(user_signer), 100), 4);
        wallet::assert_wallet_has_sufficient_move_balance(tuser_id, 200);
        assert!(coin::balance<aptos_coin::AptosCoin>(signer::address_of(user_signer)) == 200, 5);
        assert!(coin::balance<aptos_coin::AptosCoin>(signer::address_of(aaron)) == 800, 6);
    }

    #[test(resource_account = @core, admin = @publisher, aaron = @0xCAFE)]
    fun test_fa_basic_flow(resource_account: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, resource_account);
        let token_metadata = test_utils::create_and_mint_test_token(aaron, 1000);

        let tuser_id: String = utf8(b"First User");

        let user_signer = &user::get_user_signer(admin, tuser_id);

        wallet::assert_wallet_has_sufficient_fa_balance(tuser_id, token_metadata, 0);

        wallet::fund_fa_for_wallet_by_twitter_user_id(aaron, tuser_id, token_metadata, 100);
        wallet::assert_wallet_has_sufficient_fa_balance(tuser_id, token_metadata, 100);
        assert!(primary_fungible_store::balance(signer::address_of(user_signer), token_metadata) == 100, 1);
        assert!(primary_fungible_store::balance(signer::address_of(aaron), token_metadata) == 900, 2);

        wallet::fund_fa_for_wallet_by_user_address(aaron, signer::address_of(user_signer), token_metadata, 100);
        wallet::assert_wallet_has_sufficient_fa_balance(tuser_id, token_metadata, 200);
        assert!(primary_fungible_store::balance(signer::address_of(user_signer), token_metadata) == 200, 3);
        assert!(primary_fungible_store::balance(signer::address_of(aaron), token_metadata) == 800, 4);
    }

    #[test(resource_account = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x13001, location = core::wallet)]
    fun test_wallet_insufficient_move_balance_assertion(resource_account: &signer, admin: &signer) {
        permissions_test::setup_for_test(admin, resource_account);

        let tuser_id: String = utf8(b"First User");

        user::get_user_signer(admin, tuser_id);
        wallet::assert_wallet_has_sufficient_move_balance(tuser_id, 100);
    }

    #[test(resource_account = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x13001, location = core::wallet)]
    fun test_wallet_insufficient_fa_balance_assertion(resource_account: &signer, admin: &signer) {
        permissions_test::setup_for_test(admin, resource_account);
        let token_metadata = test_utils::create_and_mint_test_token(admin, 0);

        let tuser_id: String = utf8(b"First User");

        user::get_user_signer(admin, tuser_id);
        wallet::assert_wallet_has_sufficient_fa_balance(tuser_id, token_metadata, 100);
    }

    #[test(aptos_framework = @0x1, resource_account = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x63002, location = core::wallet)]
    fun test_user_not_registered_for_move(aptos_framework: &signer, resource_account: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, resource_account);
        test_utils::setup_account_and_fund_move(aptos_framework, aaron, 1000);

        let tuser_id: String = utf8(b"First User");
        let user_address = account::create_resource_address(&@core, *bytes(&tuser_id));
        wallet::fund_move_for_wallet_by_user_address(aaron, user_address, 100);
    }

    #[test(resource_account = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x63002, location = core::wallet)]
    fun test_user_not_registered_for_fa(resource_account: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, resource_account);
        let token_metadata = test_utils::create_and_mint_test_token(aaron, 1000);

        let tuser_id: String = utf8(b"First User");
        let user_address = account::create_resource_address(&@core, *bytes(&tuser_id));
        wallet::fund_fa_for_wallet_by_user_address(aaron, user_address, token_metadata, 100);
    }

    #[test(aptos_framework = @0x1, resource_account = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x13001, location = core::wallet)]
    fun test_insufficient_move_balance_of_caller(aptos_framework: &signer, resource_account: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, resource_account);
        test_utils::setup_account_and_fund_move(aptos_framework, aaron, 1000);

        let tuser_id: String = utf8(b"First User");

        let user_signer = &user::get_user_signer(admin, tuser_id);
        wallet::fund_move_for_wallet_by_user_address(aaron, signer::address_of(user_signer), 1100);
    }

    #[test(resource_account = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x13001, location = core::wallet)]
    fun test_insufficient_fa_balance_of_caller(resource_account: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, resource_account);
        let token_metadata = test_utils::create_and_mint_test_token(aaron, 1000);

        let tuser_id: String = utf8(b"First User");

        let user_signer = &user::get_user_signer(admin, tuser_id);
        wallet::fund_fa_for_wallet_by_user_address(aaron, signer::address_of(user_signer), token_metadata, 1100);
    }
}