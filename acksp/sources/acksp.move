module acksp::acksp
{
    use std::string::{String, Self};
    use std::table;
    use std::signer;
    use std::option;
    use std::vector;

    const E_INVALID_TIMESTAMP: u64 = 1;

    struct KeyStore has key
    {
        keys: vector<Key>
    }
    struct Key has store,copy,drop
    {
        public_key: vector<u8>,
        encrypted_private_key: vector<u8>,
        from_timestamp: u64,
        to_timestamp:u64
    }
 


    public entry fun add_key(admin: &signer, public_key: vector<u8>, encrypted_private_key: vector<u8> , to_timestamp: u64) acquires KeyStore
    {
        let signer_address = signer::address_of(admin);

        if( !exists<KeyStore>(signer_address))
        {
            move_to<KeyStore>(admin, KeyStore{
                keys: vector::empty()
            });
        };

        let store = borrow_global_mut<KeyStore>(signer_address);

        assert!( 0x1::timestamp::now_seconds() < to_timestamp , E_INVALID_TIMESTAMP );

        let key = Key{
            public_key: public_key,
            encrypted_private_key: encrypted_private_key,
            from_timestamp: 0x1::timestamp::now_microseconds()/1000,
            to_timestamp: to_timestamp ,
        };

        vector::push_back(&mut store.keys , key);

    }


    #[view]
    public fun get_keys(user: address): vector<Key> acquires KeyStore
    {

        if( !exists<KeyStore>(user))
        {
            return vector::empty()
        };

        let store = borrow_global_mut<KeyStore>(user);

        return store.keys
    }

    #[view]
    public fun get_latest_key(user: address): option::Option<Key> acquires KeyStore
    {
        if( !exists<KeyStore>(user))
        {
            return option::none()
        };
        

        let store = borrow_global_mut<KeyStore>(user);
        let last_key_index = vector::length(&store.keys) - 1;


        return option::some(*vector::borrow(&store.keys , last_key_index))

    }
    
    #[view]
    public fun get_key_timestamp(user: address , timestamp: u64 ): option::Option<Key> acquires KeyStore
    {
        if( !exists<KeyStore>(user))
        {
            return option::none()
        };
        

        let store = borrow_global_mut<KeyStore>(user);
        let size = vector::length(&store.keys);


        let index = size - 1;

        while( index > 0 )
        {
            let key = *vector::borrow(&store.keys , index);
            if( key.from_timestamp < timestamp)
            {
                return option::some(key)
            };
            index = index - 1;
        };

        let key = *vector::borrow(&store.keys , index);
        if( key.from_timestamp < timestamp)
        {
            return option::some(key)
        }
        else
        {
            return option::none()
        }
 
    }
}
