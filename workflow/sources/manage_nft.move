module workflow::manage_nft {
    use std::signer;
    use std::string::{String};
    
    use core::user;

    use nft::nft_manager;

    public entry fun create_nft(caller: &signer, tuser_id: String, profile_uri: String, tweet_id: String, image_uri: String) {
        let user_signer = &user::get_user_signer(caller, tuser_id);

        nft_manager::create_nft(user_signer, tuser_id, tweet_id, profile_uri, image_uri);
    }

    public entry fun create_soul_bound(caller: &signer, tuser_id: String, profile_uri: String, tweet_id: String, image_uri: String, recipent: address) {
        let user_signer = &user::get_user_signer(caller, tuser_id);

        nft_manager::create_soul_bound(user_signer, tuser_id, tweet_id, profile_uri, image_uri, recipent);
    }

    public entry fun create_soul_bound_for_self(caller: &signer, tuser_id: String, profile_uri: String, tweet_id: String, image_uri: String) {
        let user_signer = &user::get_user_signer(caller, tuser_id);

        nft_manager::create_soul_bound(user_signer, tuser_id, tweet_id, profile_uri, image_uri, signer::address_of(user_signer));
    }

    public entry fun transfer_nft(caller: &signer, tuser_id: String, nft_name: String, recipent: address) {
        let user_signer = &user::get_user_signer(caller, tuser_id);

        nft_manager::transfer_nft_by_name(user_signer, nft_name, recipent);
    }

}