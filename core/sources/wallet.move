module core::wallet {
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;
    use aptos_framework::object::{Object};
    use aptos_framework::primary_fungible_store;
    use aptos_framework::fungible_asset::{Metadata};

    use std::signer;
    use std::string::{String};

    use core::user;
    use core::event;
    use core::error;

    const WALLET_MODULE: vector<u8> = b"wallet";

    const WALLET_TOPUP_BY_TUSER_ID_ACTION: vector<u8> = b"WALLET_TOPUP_BY_TUSER_ID_ACTION";
    const WALLET_TOPUP_BY_USER_ADDRESS_ACTION: vector<u8> = b"WALLET_TOPUP_BY_USER_ADDRESS_ACTION";

    #[event]
    struct WalletTopupByUserAddressEvent has drop, store {
        user_address: address,
        amount: u64
    }

    #[event]
    struct WalletTopupByTUserIDEvent has drop, store {
        tuser_id: String,
        amount: u64
    }

    #[test_only]
    public fun is_wallet_topup_by_user_address_event_emitted(caller: &signer, user_address: address, amount: u64): bool {
        event::has_core_event_emitted(
            caller, WALLET_MODULE, WALLET_TOPUP_BY_USER_ADDRESS_ACTION, 
            WalletTopupByUserAddressEvent{
                user_address,
                amount
        })
    }

    #[test_only]
    public fun is_wallet_topup_by_tuser_id_event_emitted(caller: &signer, tuser_id: String, amount: u64): bool {
        event::has_core_event_emitted(
            caller, WALLET_MODULE, WALLET_TOPUP_BY_TUSER_ID_ACTION, 
            WalletTopupByTUserIDEvent{
                tuser_id,
                amount
        })
    }

    #[view]
    public fun wallet_move_balance(tuser_id: String): u64 {
        let user_address = user::get_user_address(tuser_id);

        coin::balance<aptos_coin::AptosCoin>(user_address)
    }

    #[view]
    public fun wallet_fa_balance(tuser_id: String, token_metadata: Object<Metadata>): u64 {
        let user_address = user::get_user_address(tuser_id);

        primary_fungible_store::balance(user_address, token_metadata)
    }

    public fun assert_wallet_has_sufficient_move_balance(tuser_id: String, min_balance: u64) {
        let user_address = user::get_user_address(tuser_id);

        assert!(
            coin::is_balance_at_least<aptos_coin::AptosCoin>(user_address, min_balance),
            error::insufficient_balance()
        );
    }

    public fun assert_wallet_has_sufficient_fa_balance(tuser_id: String, token_metadata: Object<Metadata>, min_balance: u64) {
        let user_address = user::get_user_address(tuser_id);

        assert!(
            primary_fungible_store::is_balance_at_least(user_address, token_metadata, min_balance),
            error::insufficient_balance()
        );
    }

    public entry fun fund_move_for_wallet_by_user_address(caller: &signer, user_address: address, amount: u64) {
        let caller_address = signer::address_of(caller);

        if(!user::check_valid_user_address(user_address)) {
            abort error::invalid_user_address()
        };

        if(!coin::is_balance_at_least<aptos_coin::AptosCoin>(caller_address, amount)) {
            abort error::insufficient_balance()
        };

        coin::transfer<aptos_coin::AptosCoin>(caller, user_address, amount);

        // emit event
        event::emit_core_event(
            caller, WALLET_MODULE, WALLET_TOPUP_BY_USER_ADDRESS_ACTION, 
            WalletTopupByUserAddressEvent{
                user_address,
                amount
        });

        // add fallback logic to emit events for failed tweets.
    }

    public entry fun fund_move_for_wallet_by_twitter_user_id(caller: &signer, tuser_id: String, amount: u64) {
        let user_signer = &user::get_user_signer_internal(caller, tuser_id);

        fund_move_for_wallet_by_user_address(caller, signer::address_of(user_signer), amount);

        // emit event
        event::emit_core_event(
            caller, WALLET_MODULE, WALLET_TOPUP_BY_TUSER_ID_ACTION, 
            WalletTopupByTUserIDEvent{
                tuser_id,
                amount
        });
    }

    // Fund Fungible Asset
    public entry fun fund_fa_for_wallet_by_user_address(caller: &signer, user_address: address, token_metadata: Object<Metadata>, amount: u64) {
        let caller_address = signer::address_of(caller);

        if(!user::check_valid_user_address(user_address)) {
            abort error::invalid_user_address()
        };

        if(!primary_fungible_store::is_balance_at_least(caller_address, token_metadata, amount)) {
            abort error::insufficient_balance()
        };

        primary_fungible_store::transfer(caller, token_metadata, user_address, amount);
    }

    public entry fun fund_fa_for_wallet_by_twitter_user_id(caller: &signer, tuser_id: String, token_metadata: Object<Metadata>, amount: u64) {
        let user_signer = &user::get_user_signer_internal(caller, tuser_id);
        
        fund_fa_for_wallet_by_user_address(caller, signer::address_of(user_signer), token_metadata, amount);
    }

    // Fund Other Coins
}