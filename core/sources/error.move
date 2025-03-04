module core::error {
    use std::error;

    // 0x1 -> User module
    const E_USER_NOT_REGISTERED: u64 = 0x1001;
    const E_USER_ALREADY_REGISTERED: u64 = 0x1002;

    // 0x2 -> Permission module
    const E_NOT_AUTHORIZED: u64 = 0x2001;
    const E_ALREADY_INITALIZED: u64 = 0x2002;

    // 0x3 -> Wallet module
    const E_INSUFFICIENT_BALANCE: u64 = 0x3001;
    const E_INVALID_USER_ADDRESS: u64 = 0x3002;

    // 0x4 -> Fee Module
    const E_INVALID_BOUND: u64 = 0x4001;

    // 0x5 -> Token Package
    const E_COIN_EXISTS: u64 = 0x5001;
    const E_SUPPLY_EXCEEDED: u64 = 0x5002;
    const E_METADATA_DOES_NOT_EXIST: u64 = 0x5003;
    const E_NOT_TOKEN_OWNER: u64 = 0x5004;
    const E_NOT_VERIFIED_TOKEN_SYMBOL: u64 = 0x5005;

    // 0x6 -> NFT Package
    const E_NFT_LIMIT_EXHAUSTED: u64 = 0x6001;
    const E_COLLECTION_NOT_FOUND: u64 = 0x6002;
    const E_NFT_NOT_FOUND: u64 = 0x6003;
    const E_NFT_NOT_TRANSFERRABLE: u64 = 0x6004;
    const E_NOT_NFT_OWNER: u64 = 0x6005;

    public fun not_authorized(): u64 {
        error::permission_denied(E_NOT_AUTHORIZED)
    }

    public fun already_initialized(): u64 {
        error::aborted(E_ALREADY_INITALIZED)
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

    public fun token_already_exists(): u64 {
        error::already_exists(E_COIN_EXISTS)
    }

    public fun max_supply_exceeded(): u64 {
        error::out_of_range(E_SUPPLY_EXCEEDED)
    }

    public fun metadata_does_not_exist(): u64 {
        error::not_found(E_METADATA_DOES_NOT_EXIST)
    }

    public fun not_token_owner(): u64 {
        error::permission_denied(E_NOT_TOKEN_OWNER)
    }

    public fun not_verified_token_symbol(): u64 {
        error::not_found(E_NOT_VERIFIED_TOKEN_SYMBOL)
    }

    public fun nft_limit_exhausted(): u64 {
        error::out_of_range(E_NFT_LIMIT_EXHAUSTED)
    }

    public fun collection_not_found(): u64 {
        error::not_found(E_COLLECTION_NOT_FOUND)
    }

    public fun nft_not_found(): u64 {
        error::not_found(E_NFT_NOT_FOUND)
    }

    public fun nft_not_transferrable(): u64 {
        error::permission_denied(E_NFT_NOT_TRANSFERRABLE)
    }

    public fun nft_not_owner(): u64 {
        error::permission_denied(E_NOT_NFT_OWNER)
    }
}