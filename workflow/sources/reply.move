module workflow::reply {
    use std::string::{String};

    // use core::fee;
    use core::user;
    // use core::wallet;

    const FLAT_FEE_FOR_REPLY: u64 = 10000000;

    const REPLY_MODULE: vector<u8> = b"reply";
    const REPLY_TWEET_ACTION: vector<u8> = b"REPLY_TWEET_ACTION";

    #[event]
    struct ReplyTweetEvent has drop, store {}

    #[view]
    public fun estimate_cost_in_move(): u64 {
        // FLAT_FEE_FOR_REPLY
        0
    }

    #[test_only]
    public fun has_reply_tweet_event_emitted(caller: &signer, user_signer: &signer, tweet_id: String): bool {
        user::is_workflow_event_emitted(caller, user_signer, tweet_id, REPLY_MODULE, REPLY_TWEET_ACTION, ReplyTweetEvent{})
    }

    public entry fun execute(caller: &signer, tuser_id: String, tweet_id: String) {
        let user_signer = &user::get_user_signer(caller, tuser_id);

        // fee::charge_move_flat_fee(user_signer, FLAT_FEE_FOR_REPLY);

        // emit event
        user::emit_workflow_event(caller, user_signer, tweet_id, REPLY_MODULE, REPLY_TWEET_ACTION, ReplyTweetEvent{});
    }

    // add to queue fallback function (entry)

}