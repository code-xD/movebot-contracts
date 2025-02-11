module workflow::reply {
    use std::string::{String};

    use core::fee;
    use core::user;
    use core::wallet;

    const FLAT_FEE_FOR_REPLY: u64 = 10000000;

    #[view]
    public fun estimate_cost_in_move(): u64 {
        // FLAT_FEE_FOR_REPLY
        0
    }

    public entry fun execute(caller: &signer, tuser_id: String, tweet_id: String) {
        let user_signer = &user::get_user_signer(caller, tuser_id);

        // fee::charge_move_flat_fee(user_signer, FLAT_FEE_FOR_REPLY);

        // emit event
    }

    // add to queue fallback function (entry)

}