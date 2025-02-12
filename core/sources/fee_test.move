#[test_only]
module core::fee_test {
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;

    use std::signer;
    use std::option;
    use std::string::{utf8, String};

    use core::fee;
    use core::user;
    use core::wallet;
    use core::test_utils;
    use core::permissions_test;

    fun create_and_topup_test_user(aptos_framework: &signer, admin: &signer, aaron: &signer, tuser_id: String): signer {
        test_utils::setup_account_and_fund_move(aptos_framework, aaron, 1000);

        let user_signer = user::get_user_signer(admin, tuser_id);
        wallet::fund_move_for_wallet_by_twitter_user_id(aaron, tuser_id, 1000);

        user_signer
    }


    #[test(aptos_framework = @0x1, resource_account = @core, admin = @publisher, aaron = @0xCAFE)]
    fun test_basic_flow(aptos_framework: &signer, resource_account: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, resource_account);

        let tuser_id: String = utf8(b"First User");
        let user_signer = &create_and_topup_test_user(aptos_framework, admin, aaron, tuser_id);        

        fee::charge_move_flat_fee(user_signer, 100);
        assert!(fee::is_flat_fee_charged_event_emitted(user_signer, 100), 1);
        assert!(coin::balance<aptos_coin::AptosCoin>(signer::address_of(user_signer)) == 900, 2);
        assert!(coin::balance<aptos_coin::AptosCoin>(signer::address_of(resource_account)) == 100, 3);

        fee::charge_move_fee_with_percentage(user_signer, 100000, 1000, option::none(), option::none());
        assert!(fee::is_percentage_fee_charged_event_emitted(user_signer, 100000, 1000, 1, option::none(), option::none()), 4);
        assert!(coin::balance<aptos_coin::AptosCoin>(signer::address_of(resource_account)) == 101, 5);

        fee::charge_move_fee_with_percentage(user_signer, 100000, 20000, option::none(), option::some<u64>(10));
        assert!(fee::is_percentage_fee_charged_event_emitted(user_signer, 100000, 20000, 10, option::none(), option::some<u64>(10)), 5);
        assert!(coin::balance<aptos_coin::AptosCoin>(signer::address_of(resource_account)) == 111, 6);

        fee::charge_move_fee_with_percentage(user_signer, 100000, 4000, option::some<u64>(5), option::some<u64>(10));
        assert!(fee::is_percentage_fee_charged_event_emitted(user_signer, 100000, 4000, 5, option::some<u64>(5), option::some<u64>(10)), 7);
        assert!(coin::balance<aptos_coin::AptosCoin>(signer::address_of(resource_account)) == 116, 8);
    }

    #[test(aptos_framework = @0x1, resource_account = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x14001, location = core::fee)]
    fun test_bounds_fail_check(aptos_framework: &signer, resource_account: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, resource_account);

        let tuser_id: String = utf8(b"First User");
        let user_signer = &create_and_topup_test_user(aptos_framework, admin, aaron, tuser_id);        

        fee::charge_move_fee_with_percentage(user_signer, 100000, 4000, option::some<u64>(11), option::some<u64>(10));
    }

    #[test(aptos_framework = @0x1, resource_account = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x63002, location = core::fee)]
    fun test_invalid_user_address(aptos_framework: &signer, resource_account: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, resource_account);

        test_utils::setup_account_and_fund_move(aptos_framework, aaron, 1000);
        fee::charge_move_flat_fee(aaron, 100);
    }

    #[test(aptos_framework = @0x1, resource_account = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x63002, location = core::fee)]
    fun test_insufficient_balance(aptos_framework: &signer, resource_account: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, resource_account);

        let tuser_id: String = utf8(b"First User");
        create_and_topup_test_user(aptos_framework, admin, aaron, tuser_id);

        fee::charge_move_flat_fee(aaron, 1100);
    }
}