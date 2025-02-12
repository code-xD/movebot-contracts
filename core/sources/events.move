module core::event {
    use std::signer;
    use std::string::{utf8, String};

    use aptos_framework::event;

    friend core::fee;
    friend core::user;
    friend core::wallet;

    #[event]
    struct CoreEvent<T: drop + store> has drop, store {
        caller: address,
        scope: String,
        action: String,
        metadata: T
    }

    #[event]
    struct WorkflowEvent<T: drop + store> has drop, store {
        caller: address,
        user_address: address,
        tuser_id: String,
        tweet_id: String,
        scope: String,
        action: String,
        metadata: T
    }

    public(friend) fun emit_core_event<T: drop + store>(caller: &signer, scope: vector<u8>, action: vector<u8>, metadata: T) {
        let core_event = CoreEvent{
            caller: signer::address_of(caller),
            scope: utf8(scope),
            action: utf8(action),
            metadata
        };

        event::emit(core_event);
    }

    public(friend) fun emit_workflow_event<T: drop + store>(caller: &signer, user_address: address, tuser_id: String, tweet_id: String, scope: vector<u8>, action: vector<u8>, metadata: T) {
        let workflow_event = WorkflowEvent{
            caller: signer::address_of(caller),
            tuser_id,
            user_address,
            tweet_id,
            scope: utf8(scope),
            action: utf8(action),
            metadata
        };

        event::emit(workflow_event);
    }

    #[test_only]
    public fun has_core_event_emitted<T: drop + store>(caller: &signer, scope: vector<u8>, action: vector<u8>, metadata: T): bool {
        let core_event = CoreEvent{
            caller: signer::address_of(caller),
            scope: utf8(scope),
            action: utf8(action),
            metadata
        };

        event::was_event_emitted(&core_event)
    }

    #[test_only]
    public fun has_workflow_event_emitted<T: drop + store>(caller: &signer, user_address: address, tuser_id: String, tweet_id: String, scope: vector<u8>, action: vector<u8>, metadata: T): bool {
        let core_event = WorkflowEvent{
            caller: signer::address_of(caller),
            tuser_id,
            user_address,
            tweet_id,
            scope: utf8(scope),
            action: utf8(action),
            metadata
        };

        event::was_event_emitted(&core_event)
    }
}