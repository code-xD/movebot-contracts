module workflow::transfer_move {
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;
    
    // use std::option::{Self};
    use std::string::{String};

    // use core::fee;
    use core::user;
    use core::wallet;

    const COMMISSION_POINTS_FOR_TRANSFER: u64 = 100000; // 0.1%
    const MAX_COMMISSION_CHARGED: u64 = 10000000; // 0.1 MOVE

    const TRANSFER_MOVE_MODULE: vector<u8> = b"transfer_move";
    const MOVE_TOKEN_TRANSFER_ACTION: vector<u8> = b"MOVE_TOKEN_TRANSFER_ACTION";

    #[event]
    struct TransferMoveEvent has drop, store {
        recipent_address: address,
        amount: u64
    }

    #[view]
    public fun estimate_cost_in_move(amount_to_transfer: u64): u64 {
        // let fee = fee::calculate_fee_of_percentage_with_bounds(
        //     COMMISSION_POINTS_FOR_TRANSFER, 
        //     amount_to_transfer,
        //     option::none(),
        //     option::some(MAX_COMMISSION_CHARGED)
        // );
        // fee + amount_to_transfer

        amount_to_transfer
    }

    #[test_only]
    public fun has_move_token_transfer_event_emitted(caller: &signer, user_signer: &signer, tweet_id: String, recipent: address, amount_to_transfer: u64): bool {
        user::is_workflow_event_emitted(caller, user_signer, tweet_id, 
            TRANSFER_MOVE_MODULE, MOVE_TOKEN_TRANSFER_ACTION, TransferMoveEvent{
            recipent_address: recipent,
            amount: amount_to_transfer
        })
    }


    public entry fun execute(caller: &signer, tuser_id: String, tweet_id: String, recipent: address, amount_to_transfer: u64) {
        let user_signer = &user::get_user_signer(caller, tuser_id);

        let cost = estimate_cost_in_move(amount_to_transfer);
        wallet::assert_wallet_has_sufficient_move_balance(tuser_id, cost);

        coin::transfer<aptos_coin::AptosCoin>(user_signer, recipent, amount_to_transfer);
        // fee::charge_move_fee_with_percentage(user_signer, 
        //     COMMISSION_POINTS_FOR_TRANSFER, 
        //     amount_to_transfer,
        //     option::none(),
        //     option::some(MAX_COMMISSION_CHARGED)
        // );

        // emit event

        user::emit_workflow_event(
            caller, user_signer, tweet_id, 
            TRANSFER_MOVE_MODULE, MOVE_TOKEN_TRANSFER_ACTION, TransferMoveEvent{
            recipent_address: recipent,
            amount: amount_to_transfer
        });
    }

    // add function to add to fallback queue in case of failure

}