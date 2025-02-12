module token::manager {
    use aptos_framework::object::{Self, Object};
    use aptos_framework::primary_fungible_store;
    use aptos_framework::fungible_asset::{Self, MintRef, Metadata};

    use std::signer;
    use std::option;
    use std::string::{bytes, String};

    use core::user;
    use core::error;
    
    const MAX_SUPPLY: u128 = 1000_000_000_0000_0000; // 1B

    #[view]
    public fun get_metadata(creator: address, symbol: String): Object<Metadata> {
        let metadata_address = object::create_object_address(&creator, *bytes(&symbol));

        assert!(
            object::object_exists<Metadata>(metadata_address),
            error::metadata_does_not_exist()
        );

        object::address_to_object<Metadata>(metadata_address)
    }

    fun mint(mint_ref: MintRef, metadata: Object<Metadata>, to: address, amount: u64) {
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, metadata);
        fungible_asset::mint_to(&mint_ref, to_wallet, amount);
    }

    public fun create_token(
        sender: &signer, 
        name: String, 
        symbol: String, 
        supply: u128,
        icon_uri: String, 
        project_uri: String
    ): Object<Metadata> {
        assert!(
            user::check_valid_user_address(signer::address_of(sender)),
            error::invalid_user_address()
        );

        let object_address = object::create_object_address(&signer::address_of(sender), *bytes(&symbol));
        let fa_exists = object::object_exists<Metadata>(object_address);
        assert!(!fa_exists, error::token_already_exists());

        assert!(supply < MAX_SUPPLY, error::max_supply_exceeded());

        let constructor_ref = &object::create_named_object(sender, *bytes(&symbol)); 

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
        mint(mint_ref, metadata, signer::address_of(sender), (supply as u64));
        metadata
    }

    public fun transfer_token_ownership(sender: &signer, token_metadata: Object<Metadata>, to: address) {
        assert!(
            user::check_valid_user_address(signer::address_of(sender)),
            error::invalid_user_address()
        );

        assert!(
            object::is_owner(token_metadata, signer::address_of(sender)),
            error::not_token_owner()
        );

        object::transfer(sender, token_metadata, to);
    }

    public fun transfer_token(sender: &signer, token_metadata: Object<Metadata>, to: address, amount: u64) {
        let sender_address = signer::address_of(sender);

        assert!(
            user::check_valid_user_address(sender_address),
            error::invalid_user_address()
        );

        if(!primary_fungible_store::is_balance_at_least(sender_address, token_metadata, amount)) {
            abort error::insufficient_balance()
        };

        primary_fungible_store::transfer(sender, token_metadata, to, amount);
    }

}