module core::error {
    use std::error;

    // 0x1 -> User module
    const E_USER_NOT_REGISTERED: u64 = 0x1001;
    const E_USER_ALREADY_REGISTERED: u64 = 0x1002;

    // 0x2 -> Permission module
    const E_NOT_AUTHORIZED: u64 = 0x2001;

    // 0x3 -> Wallet module
    const E_INSUFFICIENT_BALANCE: u64 = 0x3001;
    const E_INVALID_USER_ADDRESS: u64 = 0x3002;

    // 0x4 -> Fee Module
    const E_INVALID_BOUND: u64 = 0x4001;

    public fun not_authorized(): u64 {
        error::permission_denied(E_NOT_AUTHORIZED)
    }

    public fun user_not_registered(): u64 {
        error::permission_denied(E_USER_NOT_REGISTERED)
    }

    public fun user_already_registered(): u64 {
        error::already_exists(E_USER_ALREADY_REGISTERED)
    }

    public fun insufficient_balance(): u64 {
        error::invalid_argument(E_INSUFFICIENT_BALANCE)
    }

    public fun invalid_user_address(): u64 {
        error::not_found(E_INVALID_USER_ADDRESS)
    }

    public fun invalid_bound(): u64 {
        error::invalid_argument(E_INVALID_BOUND)
    }
}