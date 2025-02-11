module core::upgrade { 
    use core::permissions;
    use aptos_framework::code;

    public entry fun upgrade_package(
        admin_signer: &signer,
        metadata_serialized: vector<u8>,
        bytecode: vector<vector<u8>>
    ) {
        let resource_signer = permissions::get_signer(admin_signer);

        // Perform the upgrade using the resource account's signer
        code::publish_package_txn(
            &resource_signer,
            metadata_serialized,
            bytecode
        );
    }
}