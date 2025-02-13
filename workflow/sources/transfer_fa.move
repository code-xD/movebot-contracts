module workflow::transfer_fa {
    use aptos_framework::object::{Object};
    use aptos_framework::fungible_asset::{Metadata};

    use std::signer;
    use std::string::{String};

    use core::user;
    use token::manager;
    use token::repository;

    public entry fun transfer_token_by_tuser_id_and_symbol(caller: &signer, tuser_id: String, token_tuser_id: String, symbol: String, to: address, amount: u64) {
        let user_signer = &user::get_user_signer(caller, tuser_id);
        let token_owner_address = user::get_user_address(token_tuser_id);

        let token_metadata = manager::get_metadata(token_owner_address, symbol);

        manager::transfer_token(user_signer, token_metadata, to, amount);
    }

    public entry fun transfer_token_by_verified_symbol(caller: &signer, tuser_id: String, symbol: String, to: address, amount: u64) {
        let user_signer = &user::get_user_signer(caller, tuser_id);
        let token_metadata = repository::get_metadata_for_verified_fa(symbol);

        manager::transfer_token(user_signer, token_metadata, to, amount);
    }

    public entry fun transfer_token_by_token_address(caller: &signer, tuser_id: String, token_address: Object<Metadata>, to: address, amount: u64) {
        let user_signer = &user::get_user_signer(caller, tuser_id);

        manager::transfer_token(user_signer, token_address, to, amount);
    }

}