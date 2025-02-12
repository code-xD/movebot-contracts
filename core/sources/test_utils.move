#[test_only]
module core::test_utils {
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;
    use aptos_framework::aptos_account;

    use std::signer;

    public fun setup_account_and_fund_move(framework: &signer, user: &signer, amount: u64) {
        aptos_account::create_account(signer::address_of(user));
        
        coin::register<aptos_coin::AptosCoin>(user);
        aptos_coin::mint(framework, signer::address_of(user), amount);
    }
}