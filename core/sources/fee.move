module core::fee {
    // %age -> % of amount
    // Flat -> fixed amount
    // Tiered

    use aptos_framework::coin;
    use aptos_framework::aptos_coin;

    use std::signer;
    use std::math64;
    use std::option::{Self, Option};

    use core::user;
    use core::event;
    use core::error;

    const BASE_VALUE: u64 = 100000000;
    const MAX_U64: u64 = 0xFFFFFFFFFFFFFFFF;

    const FEE_MODULE: vector<u8> = b"fee";

    const FLAT_FEE_CHARGED_ACTION: vector<u8> = b"FLAT_FEE_CHARGED_ACTION";
    const PERCENTAGE_FEE_CHARGED_ACTION: vector<u8> = b"PERCENTAGE_FEE_CHARGED_ACTION";

    #[event]
    struct FlatFeeArgs has drop, store {
        fee: u64
    }

    #[event]
    struct PercentageFeeArgs has drop, store {
        fee: u64,
        amount: u64,
        commission: u64,
        lower_bound: Option<u64>,
        upper_bound: Option<u64>
    }

    // transfer_fa_fee_to_bot
    // transfer_coin_fee_to_bot
    fun transfer_move_fee_to_bot(sender: &signer, fee: u64) {
        let user_address = signer::address_of(sender);
        if(!user::check_valid_user_address(user_address)) {
            abort error::invalid_user_address()
        };

        if(!coin::is_balance_at_least<aptos_coin::AptosCoin>(user_address, fee)) {
            abort error::insufficient_balance()
        };

        coin::transfer<aptos_coin::AptosCoin>(sender, @core, fee);
    }

    #[view]
    public fun calculate_fee_of_percentage_with_bounds(commission: u64, amount: u64, lower_bound: Option<u64>, upper_bound: Option<u64>): u64 {
        if(option::is_some(&lower_bound) && option::is_some(&upper_bound)) {
            assert!(
                option::get_with_default(&lower_bound, 0) <= option::get_with_default(&upper_bound, 0),
                error::invalid_bound()
            );
        };

        let fee = (amount * commission / BASE_VALUE);

        fee = math64::max(fee, option::get_with_default(&lower_bound, 0));
        fee = math64::min(fee, option::get_with_default(&upper_bound, MAX_U64));

        fee
    }

    #[test_only]
    public fun is_flat_fee_charged_event_emitted(caller: &signer, fee: u64): bool {
        event::has_core_event_emitted(
            caller, FEE_MODULE, FLAT_FEE_CHARGED_ACTION, 
            FlatFeeArgs{fee}
        )
    }

    #[test_only]
    public fun is_percentage_fee_charged_event_emitted(sender: &signer, commission: u64, amount: u64, fee: u64, lower_bound: Option<u64>, upper_bound: Option<u64>): bool {
        event::has_core_event_emitted(sender, FEE_MODULE, PERCENTAGE_FEE_CHARGED_ACTION, 
            PercentageFeeArgs{
                fee,
                amount,
                commission,
                lower_bound,
                upper_bound
            }
        )
    }

    public fun charge_move_fee_with_percentage(sender: &signer, commission: u64, amount: u64, lower_bound: Option<u64>, upper_bound: Option<u64>) {
        let fee = calculate_fee_of_percentage_with_bounds(commission, amount, lower_bound, upper_bound);
        transfer_move_fee_to_bot(sender, fee);

        //emit event
        event::emit_core_event(sender, FEE_MODULE, PERCENTAGE_FEE_CHARGED_ACTION, 
            PercentageFeeArgs{
                fee,
                amount,
                commission,
                lower_bound,
                upper_bound
            }
        );
    }

    public fun charge_move_flat_fee(sender: &signer, fee: u64) {
        transfer_move_fee_to_bot(sender, fee);

        // emit event
        event::emit_core_event(sender, FEE_MODULE, FLAT_FEE_CHARGED_ACTION, FlatFeeArgs{fee});
    }

}