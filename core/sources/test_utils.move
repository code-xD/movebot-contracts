#[test_only]
module core::test_utils {
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;
    use aptos_framework::aptos_account;
    use aptos_framework::object::{Self, Object};
    use aptos_framework::primary_fungible_store;
    use aptos_framework::fungible_asset::{Self, Metadata};

    use std::signer;
    use std::option;
    use std::string::{utf8, bytes, String};

    public fun setup_account_and_fund_move(framework: &signer, user: &signer, amount: u64) {
        aptos_account::create_account(signer::address_of(user));
        
        coin::register<aptos_coin::AptosCoin>(user);
        aptos_coin::mint(framework, signer::address_of(user), amount);
    }

    public fun create_and_mint_test_token(creator: &signer, amount: u64): Object<Metadata> {
        let symbol: String = utf8(b"TST");
        let name: String = utf8(b"TST");
        let supply: u128 = (amount as u128);

        let icon_uri: String = utf8(b"http://test.com/fav.ico");
        let project_uri: String = utf8(b"http://test.com");

        let constructor_ref = &object::create_named_object(creator, *bytes(&symbol)); 

        // Create the FA's Metadata with your name, symbol, icon, etc.
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::some(supply),
            name,
            symbol,
            8,
            icon_uri,
            project_uri
        );
 
        // Generate mint ref
        let mint_ref = fungible_asset::generate_mint_ref(constructor_ref);
        let metadata = object::object_from_constructor_ref<Metadata>(constructor_ref);

        // mint all supply to custodial wallet
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(
            signer::address_of(creator), metadata);

        fungible_asset::mint_to(&mint_ref, to_wallet, (supply as u64));

        metadata
    }
}