#[test_only]
module nft::nft_manager_test {
    use aptos_token_objects::token;

    use aptos_framework::object;

    use aptos_std::debug;

    use std::signer;
    use std::string::{utf8, String};

    use core::user;
    use core::permissions_test;

    use nft::nft_manager;
    

    #[test(core = @core, admin = @publisher, aaron = @0xCAFE)]
    fun test_basic_flow(core: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, core);

        let tuser_id: String = utf8(b"First User");
        let user_signer = &user::get_user_signer(admin, tuser_id);

        let tweet_id: String = utf8(b"test_tweet");
        let profile_uri: String = utf8(b"test_profile_uri");
        let image_uri: String = utf8(b"test_image_uri");

        nft_manager::create_nft(user_signer, tuser_id, tweet_id, profile_uri, image_uri);

        let nft_name = utf8(b"First User#0001");
        let nft_object = nft_manager::get_nft_object(tuser_id, nft_name);
        let nft_object_latest_minted = nft_manager::get_nft_object_by_latest_minted(tuser_id);

        debug::print(&nft_manager::get_nft_detail(tuser_id, nft_name));
        assert!(token::name(nft_object_latest_minted) == nft_name, 1);
        assert!(object::is_owner(nft_object, signer::address_of(user_signer)), 2);

        nft_manager::transfer_nft_by_name(user_signer, nft_name, signer::address_of(aaron));
        assert!(object::is_owner(nft_object, signer::address_of(aaron)), 3);

        nft_manager::create_soul_bound(user_signer, tuser_id, tweet_id, profile_uri, image_uri, signer::address_of(aaron));
        let nft_name = utf8(b"First User#0002");
        let nft_object_latest_minted = nft_manager::get_nft_object_by_latest_minted(tuser_id);
        assert!(token::name(nft_object_latest_minted) == nft_name, 4);

        debug::print(&nft_manager::get_nft_detail(tuser_id, nft_name));
        debug::print(&nft_manager::get_nft_detail_by_latest_minted(tuser_id));
    }

    #[test(core = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x66002, location = nft::nft_manager)]
    fun test_collection_not_found(core: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, core);

        let tuser_id: String = utf8(b"First User");
        let user_signer = &user::get_user_signer(admin, tuser_id);

        nft_manager::transfer_nft_by_name(user_signer, utf8(b"test"), signer::address_of(aaron));
    }

    #[test(core = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x66003, location = nft::nft_manager)]
    fun test_nft_not_found(core: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, core);

        let tuser_id: String = utf8(b"First User");
        let user_signer = &user::get_user_signer(admin, tuser_id);

        let tweet_id: String = utf8(b"test_tweet");
        let profile_uri: String = utf8(b"test_profile_uri");
        let image_uri: String = utf8(b"test_image_uri");

        nft_manager::create_nft(user_signer, tuser_id, tweet_id, profile_uri, image_uri);

        let nft_name = utf8(b"First User#0002");
        nft_manager::transfer_nft_by_name(user_signer, nft_name, signer::address_of(aaron));
    }

    #[test(core = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x56004, location = nft::nft_manager)]
    fun test_nft_not_transferrable(core: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, core);

        let tuser_id: String = utf8(b"First User");
        let user_signer = &user::get_user_signer(admin, tuser_id);

        let tweet_id: String = utf8(b"test_tweet");
        let profile_uri: String = utf8(b"test_profile_uri");
        let image_uri: String = utf8(b"test_image_uri");

        nft_manager::create_soul_bound(user_signer, tuser_id, tweet_id, profile_uri, image_uri, signer::address_of(user_signer));

        let nft_name = utf8(b"First User#0001");
        nft_manager::transfer_nft_by_name(user_signer, nft_name, signer::address_of(aaron));
    }

    #[test(core = @core, admin = @publisher, aaron = @0xCAFE)]
    #[expected_failure(abort_code = 0x56005, location = nft::nft_manager)]
    fun test_nft_not_owner(core: &signer, admin: &signer, aaron: &signer) {
        permissions_test::setup_for_test(admin, core);

        let tuser_id: String = utf8(b"First User");
        let user_signer = &user::get_user_signer(admin, tuser_id);

        let tweet_id: String = utf8(b"test_tweet");
        let profile_uri: String = utf8(b"test_profile_uri");
        let image_uri: String = utf8(b"test_image_uri");

        nft_manager::create_nft(user_signer, tuser_id, tweet_id, profile_uri, image_uri);

        let nft_name = utf8(b"First User#0001");
        nft_manager::transfer_nft_by_name(user_signer, nft_name, signer::address_of(aaron));
        nft_manager::transfer_nft_by_name(user_signer, nft_name, signer::address_of(aaron));
    }
}