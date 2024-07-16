module acmp::acmp
{
    use std::string::{String,Self};
    use std::signer;
    use aptos_framework::account;
    use std::vector;
    use std::option;
    use std::timestamp;

    struct Message has store , copy
    {
        timestamp: u64,
        payload: vector<u8>,
        from: address
    }

    struct MessageStore has key
    {
        messages : vector<Message>
    }

    public entry fun create_store(account: &signer) 
    {
        let signer_address = signer::address_of(account);
        assert!( !exists<MessageStore>(signer_address) , 1);

        let ms = MessageStore{
            messages : vector::empty()
        };

        move_to(account , ms);

    }

    public entry fun send_message(from: &signer , to: address , msg: vector<u8>) acquires MessageStore
    {
   
        let ms = borrow_global_mut<MessageStore>(to);
        vector::push_back(&mut ms.messages, Message{
            from: signer::address_of(from),
            timestamp: timestamp::now_microseconds()/1000,
            payload: msg,
        });

    } 

    #[view]
    public fun get_messages(user: address , start: u64, end: u64): vector<Message> acquires MessageStore
    {
        if(!exists<MessageStore>(user))
        {
            return vector::empty()
        };
        let ms = borrow_global_mut<MessageStore>(user);
        let end_index = vector::length(&ms.messages);
        if (end != 0 && end_index > end)
        {
            end_index = end
        };
        vector::slice(&ms.messages, start, end_index)

    }
}
