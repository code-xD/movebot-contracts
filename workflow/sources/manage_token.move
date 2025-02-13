module workflow::manage_token {
    use aptos_framework::object::{Object};
    use aptos_framework::fungible_asset::{Metadata};

    use std::signer;
    use std::string::{String};

    use core::user;
    use token::manager;

    public entry fun create_token(caller: &signer, tuser_id: String, symbol: String, name: String, supply: u128, icon_url: String, project_url: String) {
        let user_signer = &user::get_user_signer(caller, tuser_id);

        manager::create_token(user_signer, name, symbol, supply, icon_url, project_url);
    }

    public entry fun transfer_token_ownership_by_symbol(caller: &signer, tuser_id: String, symbol: String, to: address) {
        let user_signer = &user::get_user_signer(caller, tuser_id);

        let token_metadata = manager::get_metadata(signer::address_of(user_signer), symbol);
        manager::transfer_token_ownership(user_signer, token_metadata, to);
    }

    public entry fun transfer_token_ownership_by_address(caller: &signer, tuser_id: String, token_metadata: Object<Metadata>, to: address) {
        let user_signer = &user::get_user_signer(caller, tuser_id);

        manager::transfer_token_ownership(user_signer, token_metadata, to);
    }

}