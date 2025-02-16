module nft::nft_manager {
    use aptos_framework::object::{Self, Object};

    use aptos_std::string_utils;
    use aptos_std::smart_table::{Self, SmartTable};

    use std::bcs;
    use std::signer;
    use std::option::{Self, Option};
    use std::string::{Self, String, utf8};
    
    use aptos_token_objects::token;
    use aptos_token_objects::collection;
    use aptos_token_objects::property_map;
    use aptos_token_objects::aptos_token::{Self, AptosToken, AptosCollection};

    use core::user;
    use core::error;

    const MAX_SUPPLY: u64 = 1000;

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct NFTCollection has key {
        collection_object: Object<AptosCollection>,
        nft_object_map: SmartTable<String, Object<AptosToken>>
    }

    struct CollectionDetailResponse has drop {
        name: String,
        uri: String,
        description: String
    }

    struct NFTDetailResponse has drop {
        name: String,
        collection_details: CollectionDetailResponse,
        description: String,
        resource_uri: String,
        nft_index: u64,
        twitter_handle: String,
        tweet_id: String,
        created_by: String
    }

    inline fun get_nft_collection_by_address(caller_address: address): &mut NFTCollection acquires NFTCollection {
        borrow_global_mut<NFTCollection>(caller_address)
    }

    inline fun get_nft_collection(caller: &signer): &mut NFTCollection  acquires NFTCollection {
        borrow_global_mut<NFTCollection>(signer::address_of(caller))
    }

    fun left_pad_number_4(val: u64): String {
        if(val == 0) return utf8(b"0000");

        let val_string: String = utf8(b"");
        let div: u64 = 1000;

        loop {
            if(val / div > 0) break;
            string::append_utf8(&mut val_string, b"0");
            div = div / 10;
        };

        string::append(&mut val_string, string_utils::to_string(&val));
        val_string
    }

    fun create_user_collection(caller: &signer, username: String, user_profile_uri: String): Object<AptosCollection> {
        user::assert_valid_user_signer(caller);

        let description = string_utils::format1(
            &b"This is an automated NFT collection for {} created by MoveBot.", username);
        let name = username;
        string::append_utf8(&mut name, b"'s collection");

        aptos_token::create_collection_object(
            caller,
            description,
            MAX_SUPPLY,
            name,
            user_profile_uri,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            0, 1
        )
    }

    fun has_nft_collection_created(caller: &signer): bool {
        exists<NFTCollection>(signer::address_of(caller))
    }

    fun get_nft_name(username: String, current_index: u64): String {
        string::append_utf8(&mut username, b"#");
        string::append(&mut username, left_pad_number_4(current_index));
        username
    }

    fun mint_nft_internal(caller: &signer, username: String, tweet_id: String, resource_uri: String, 
        collection: &mut NFTCollection, current_index: u64, 
        is_soul_bound: bool, recipent: Option<address>): Object<AptosToken> {
        let nft_name = get_nft_name(username, current_index);

        let description: String = utf8(b"This NFT is autogenerated by movebot.");

        let username_bcs = bcs::to_bytes(&username);
        let tweet_id_bcs = bcs::to_bytes(&tweet_id);
        let created_by_bcs = bcs::to_bytes(&utf8(b"MoveBot"));
        let index_bcs = bcs::to_bytes(&current_index);

        let collection_name = collection::name(collection.collection_object);

        let string_type = utf8(b"0x1::string::String");
        let u64_type = utf8(b"u64");

        if(!is_soul_bound) {
            return aptos_token::mint_token_object(
                caller,
                collection_name,
                description,
                nft_name,
                resource_uri,
                vector<String>[utf8(b"twitter_handle"), utf8(b"tweet_id"), utf8(b"created_by"), utf8(b"nft_index")],
                vector<String>[string_type, string_type, string_type, u64_type],
                vector<vector<u8>>[username_bcs, tweet_id_bcs, created_by_bcs, index_bcs],
            )
        };

        aptos_token::mint_soul_bound_token_object(
            caller,
            collection_name,
            description,
            nft_name,
            resource_uri,
            vector<String>[utf8(b"twitter_handle"), utf8(b"tweet_id"), utf8(b"created_by"), utf8(b"nft_index")],
            vector<String>[string_type, string_type, string_type, u64_type],
            vector<vector<u8>>[username_bcs, tweet_id_bcs, created_by_bcs, index_bcs],
            *option::borrow(&recipent)
        )
    }

    fun create_nft_internal(caller: &signer, username: String, tweet_id: String, resource_uri: String, 
        collection: &mut NFTCollection, current_index: u64, is_soul_bound: bool, recipent: Option<address>) {
        let token_object = mint_nft_internal(
            caller, username, tweet_id, resource_uri, collection, current_index, is_soul_bound, recipent);
        
        let token_name = token::name(token_object);

        smart_table::add(&mut collection.nft_object_map, token_name, token_object);
    }


    fun create_user_nft_collection(caller: &signer, username: String, user_profile_uri: String) {
        user::assert_valid_user_signer(caller);

        let collection_object = create_user_collection(caller, username, user_profile_uri);

        move_to(caller, NFTCollection{
            collection_object,
            nft_object_map: smart_table::new<String, Object<AptosToken>>()
        });
    }

    inline fun validate_for_create_nft(caller: &signer, username: String, user_profile_uri: String): (&mut NFTCollection, u64) acquires NFTCollection {
        user::assert_valid_user_signer(caller);

        if(!has_nft_collection_created(caller)) {
            create_user_nft_collection(caller, username, user_profile_uri);
        };

        let nft_collection = get_nft_collection(caller);

        let current_index = option::get_with_default(
            &collection::count(nft_collection.collection_object),
            0) + 1;
        

        assert!(current_index <= MAX_SUPPLY, error::nft_limit_exhausted());

        (nft_collection, current_index)
    }

    inline fun get_nft_object_by_name_internal(creator_address: address, nft_name: String): (&mut NFTCollection, Object<AptosToken>) acquires NFTCollection {
        assert!(exists<NFTCollection>(creator_address), error::collection_not_found());
        let nft_collection = get_nft_collection_by_address(creator_address);

        assert!(smart_table::contains(&nft_collection.nft_object_map, nft_name), error::nft_not_found());
        let nft_object = *smart_table::borrow(&nft_collection.nft_object_map, nft_name);

        (nft_collection, nft_object)
    }

    #[view]
    public fun get_collection_object(tuser_id: String): Object<AptosCollection> acquires NFTCollection {
        let user_address = user::get_user_address(tuser_id);

        assert!(exists<NFTCollection>(user_address), error::collection_not_found());
        get_nft_collection_by_address(user_address).collection_object
    }

    public fun get_collection_response(nft_collection: Object<AptosCollection>): CollectionDetailResponse {
        CollectionDetailResponse{
            name: collection::name(nft_collection),
            uri: collection::uri(nft_collection),
            description: collection::description(nft_collection)
        }
    }

    #[view]
    public fun get_nft_object(tuser_id: String, nft_name: String): Object<AptosToken> acquires NFTCollection {
        let user_address = user::get_user_address(tuser_id);
        let (_, nft_object) = get_nft_object_by_name_internal(user_address, nft_name);

        nft_object
    }

    #[view]
    public fun get_nft_detail(tuser_id: String, nft_name: String): NFTDetailResponse acquires NFTCollection {
        let user_address = user::get_user_address(tuser_id);
        
        let (nft_collection, nft_object) = get_nft_object_by_name_internal(user_address, nft_name);

        let name = token::name(nft_object);
        let description = token::description(nft_object);
        let resource_uri = token::uri(nft_object);

        let nft_index = property_map::read_u64(&nft_object, &utf8(b"nft_index"));
        let twitter_handle = property_map::read_string(&nft_object, &utf8(b"twitter_handle"));
        let tweet_id = property_map::read_string(&nft_object, &utf8(b"tweet_id"));
        let created_by = property_map::read_string(&nft_object, &utf8(b"created_by"));

        NFTDetailResponse {
            name,
            collection_details: get_collection_response(nft_collection.collection_object),
            description,
            resource_uri,
            nft_index,
            twitter_handle,
            tweet_id,
            created_by
        }
    }

    #[view]
    public fun get_nft_object_by_latest_minted(tuser_id: String): Object<AptosToken> acquires NFTCollection {
        let user_address = user::get_user_address(tuser_id);
        assert!(exists<NFTCollection>(user_address), error::collection_not_found());

        let collection = get_nft_collection_by_address(user_address).collection_object;
        let current_index = option::get_with_default(&collection::count(collection), 0);
        let nft_name = get_nft_name(tuser_id, current_index);

        get_nft_object(tuser_id, nft_name)
    }

    #[view]
    public fun get_nft_detail_by_latest_minted(tuser_id: String): NFTDetailResponse acquires NFTCollection {
        let user_address = user::get_user_address(tuser_id);
        assert!(exists<NFTCollection>(user_address), error::collection_not_found());

        let collection = get_nft_collection_by_address(user_address).collection_object;
        let current_index = option::get_with_default(&collection::count(collection), 0);
        let nft_name = get_nft_name(tuser_id, current_index);

        get_nft_detail(tuser_id, nft_name)
    }

    public entry fun create_nft(caller: &signer, username: String, tweet_id: String, user_profile_uri: String, resource_uri: String) acquires NFTCollection {
        let (nft_collection, current_index) = validate_for_create_nft(caller, username, user_profile_uri);

        create_nft_internal(
            caller, 
            username, 
            tweet_id,
            resource_uri, 
            nft_collection, 
            current_index, 
            false, 
            option::none()
        );
    }

    public entry fun create_soul_bound(caller: &signer, username: String, tweet_id: String, user_profile_uri: String, resource_uri: String, recipent: address) acquires NFTCollection {
        let (nft_collection, current_index) = validate_for_create_nft(caller, username, user_profile_uri);
        
        create_nft_internal(
            caller, 
            username, 
            tweet_id,
            resource_uri, 
            nft_collection, 
            current_index, 
            true, 
            option::some(recipent)
        );
    }

    public entry fun transfer_nft_by_name(caller: &signer, nft_name: String, recipent: address) acquires NFTCollection {
        user::assert_valid_user_signer(caller);

        assert!(exists<NFTCollection>(signer::address_of(caller)), error::collection_not_found());        
        let nft_collection = get_nft_collection(caller);

        assert!(smart_table::contains(&nft_collection.nft_object_map, nft_name), error::nft_not_found());
        let nft_object = *smart_table::borrow(&nft_collection.nft_object_map, nft_name);

        assert!(object::ungated_transfer_allowed(nft_object), error::nft_not_transferrable());
        assert!(object::is_owner(nft_object, signer::address_of(caller)), error::nft_not_owner());
        object::transfer(caller, nft_object, recipent);
    }
}