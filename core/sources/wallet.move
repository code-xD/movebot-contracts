module core::wallet {
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;

    use std::string::{String};

    use core::user;
    use core::error;

    public fun assert_wallet_has_sufficient_move_balance(tuser_id: String, min_balance: u64) {
        let user_address = user::get_user_address(tuser_id);

        assert!(
            coin::is_balance_at_least<aptos_coin::AptosCoin>(user_address, min_balance),
            error::insufficient_balance()
        );
    }

    public entry fun fund_move_for_wallet_by_user_address(caller: &signer, user_address: address, amount: u64) {
        if(!user::check_valid_user_address(user_address)) {
            abort error::invalid_user_address()
        };

        if(!coin::is_balance_at_least<aptos_coin::AptosCoin>(user_address, amount)) {
            abort error::insufficient_balance()
        };

        coin::transfer<aptos_coin::AptosCoin>(caller, user_address, amount);
        // add logic to emit events for tweets which failed earlier due to insufficient balance.
    }

    public entry fun fund_move_for_wallet_by_twitter_user_id(caller: &signer, tuser_id: String, amount: u64) {
        let user_address = user::get_user_address(tuser_id);

        fund_move_for_wallet_by_user_address(caller, user_address, amount);
    }

    // Fund Fungible Asset
    // Fund Other Coins
}