module token::fa_wallet {
    use aptos_framework::primary_fungible_store;
    
    use std::string::{String};

    use core::user;
    use core::wallet;

    use token::manager;
    use token::repository;

    #[view]
    public fun wallet_fa_balance_for_user_created_token(tuser_id: String, token_owner_tuser_id: String, symbol: String): u64 {
        let user_address = user::get_user_address(tuser_id);
        let token_owner_address = user::get_user_address(token_owner_tuser_id);

        let token_metadata = manager::get_metadata(token_owner_address, symbol);
        primary_fungible_store::balance(user_address, token_metadata)
    }

    #[view]
    public fun wallet_fa_balance_for_verified_token(tuser_id: String, symbol: String): u64 {
        let user_address = user::get_user_address(tuser_id);
        let token_metadata = repository::get_metadata_for_verified_fa(symbol);

        primary_fungible_store::balance(user_address, token_metadata)
    }

    public entry fun fund_verified_fa_for_wallet_by_user_address(caller: &signer, user_address: address, symbol: String, amount: u64) {
        let token_metadata = repository::get_metadata_for_verified_fa(symbol);

        wallet::fund_fa_for_wallet_by_user_address(caller, user_address, token_metadata, amount);
    }

    public entry fun fund_verified_fa_for_wallet_by_twitter_user_id(caller: &signer, tuser_id: String, symbol: String, amount: u64) {
        let token_metadata = repository::get_metadata_for_verified_fa(symbol);

        wallet::fund_fa_for_wallet_by_twitter_user_id(caller, tuser_id, token_metadata, amount);
    }
}