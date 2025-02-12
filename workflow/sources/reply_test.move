#[test_only]
module workflow::reply_test {
    use std::string::{utf8, String};

    use core::user;
    use core::permissions_test;

    use workflow::reply;

    #[test(core = @core, admin = @publisher)]
    fun test_basic_flow(core: &signer, admin: &signer) {
        permissions_test::setup_for_test(admin, core);

        let tuser_id: String = utf8(b"First User");
        let tweet_id: String = utf8(b"http://x.com/test");

        user::create_user(admin, tuser_id);
        let user_signer = &user::get_user_signer(admin, tuser_id);

        reply::execute(admin, tuser_id, tweet_id);
        assert!(reply::has_reply_tweet_event_emitted(admin, user_signer, tweet_id), 1);
    }
}