module token::repository {
    use std::signer;
    use std::string::{String};
    
    use aptos_std::smart_table::{Self, SmartTable};

    use aptos_framework::object::{Object};
    use aptos_framework::fungible_asset::{Self, Metadata};

    use core::error;
    use core::permissions;

    struct VerifiedTokenMapping has key {
        mapping: SmartTable<String, Object<Metadata>>,
    }

    public entry fun initalize(caller: &signer) {
        let admin = &permissions::only_initializable(caller, b"repository::initialize");


        move_to(admin, VerifiedTokenMapping{
            mapping: smart_table::new<String, Object<Metadata>>()
        });
    }

    #[test_only]
    public fun setup_for_test(caller: &signer) {
        initalize(caller);
    }

    #[view]
    public fun get_metadata_for_verified_fa(symbol: String): Object<Metadata> acquires VerifiedTokenMapping {
        let token_mapping = &borrow_global<VerifiedTokenMapping>(@core).mapping;

        assert!(smart_table::contains(token_mapping, symbol), error::not_verified_token_symbol());

        *smart_table::borrow(token_mapping, symbol)
    }

    public entry fun upsert_verified_fa_metadata(caller: &signer, metadata: Object<Metadata>) acquires VerifiedTokenMapping {
        let admin = &permissions::get_signer(caller);

        let token_symbol = fungible_asset::symbol(metadata);
        let token_mapping = &mut borrow_global_mut<VerifiedTokenMapping>(signer::address_of(admin)).mapping;

        smart_table::upsert(token_mapping, token_symbol, metadata);
    }

    public entry fun remove_verified_fa_metadata(caller: &signer, symbol: String) acquires VerifiedTokenMapping {
        let admin = &permissions::get_signer(caller);

        let token_mapping = &mut borrow_global_mut<VerifiedTokenMapping>(signer::address_of(admin)).mapping;

        smart_table::remove(token_mapping, symbol);
    }
}