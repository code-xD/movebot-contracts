#[test_only]
module workflow::user_test {
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;

    use std::signer;
    use std::string::{utf8, String};

    use core::user;
    use core::wallet;
    use core::test_utils;
    use core::permissions_test;

    use workflow::transfer_move;

    #[test(aptos_framework = @0x1, core = @core, admin = @publisher, aaron = @0xFACE, bob = @0xCAFE)]
    fun test_basic_flow(aptos_framework: &signer, core: &signer, admin: &signer, aaron: &signer, bob: &signer) {
        permissions_test::setup_for_test(admin, core);
        test_utils::setup_account_and_fund_move(aptos_framework, aaron, 1000);
        test_utils::setup_account_and_fund_move(aptos_framework, bob, 0);
        
        let tuser_id: String = utf8(b"First User");
        let tweet_id: String = utf8(b"http://x.com/test");

        user::create_user(admin, tuser_id);
        let user_signer = &user::get_user_signer(admin, tuser_id);

        wallet::fund_move_for_wallet_by_twitter_user_id(aaron, tuser_id, 100);
        assert!(coin::balance<aptos_coin::AptosCoin>(signer::address_of(user_signer)) == 100, 1);

        transfer_move::execute(admin, tuser_id, tweet_id, signer::address_of(bob), 100);
        assert!(coin::balance<aptos_coin::AptosCoin>(signer::address_of(user_signer)) == 0, 2);
        assert!(coin::balance<aptos_coin::AptosCoin>(signer::address_of(bob)) == 100, 3);

        assert!(transfer_move::has_move_token_transfer_event_emitted(admin, user_signer, tweet_id, signer::address_of(bob), 100), 4);
    }

    #[test(aptos_framework = @0x1, core = @core, admin = @publisher, aaron = @0xFACE, bob = @0xCAFE)]
    #[expected_failure(abort_code = 0x13001, location = core::wallet)]
    fun test_user_wallet_insufficient_balance(aptos_framework: &signer, core: &signer, admin: &signer, aaron: &signer, bob: &signer) {
        permissions_test::setup_for_test(admin, core);
        test_utils::setup_account_and_fund_move(aptos_framework, aaron, 1000);
        test_utils::setup_account_and_fund_move(aptos_framework, bob, 0);
        
        let tuser_id: String = utf8(b"First User");

        user::create_user(admin, tuser_id);

        wallet::fund_move_for_wallet_by_twitter_user_id(aaron, tuser_id, 1100);
    }
}