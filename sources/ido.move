module presale::ido {
    use sui::object::{UID, ID};
    use sui::object;
    use sui::tx_context::TxContext;
    use std::vector;
    use sui::transfer::{public_share_object, public_transfer};
    use sui::tx_context;
    use sui::coin::Coin;
    use sui::coin;
    use sui::clock::Clock;
    use sui::clock;
    use sui::vec_map;
    use sui::vec_map::VecMap;

    const NOT_WHITELIST: u64 = 1000;
    const NOT_STARTED: u64 = 1001;
    const MAX_CAP_REACHED: u64 = 1002;
    const OWNER_ONLY: u64 = 1003;
    const USER_MAX_CAP_REACHED: u64 = 1004;
    const USER_MIN_CAP_REACHED: u64 = 1005;

    struct ManageCapAbility<phantom T> has key, store {
        id: UID,
        sale_id: ID,
    }

    struct PreSale<phantom T> has key, store {
        id: UID,
        status: u8,
        only_whitelist: bool,
        raise: u64,
        start_time: u64,
        end_time: u64,
        min_amount: u64,
        max_amount: u64,
        balance: Coin<T>,
        white_listed: vector<address>,
        members:VecMap<address,u64>,
    }

    public entry fun create_presale<T>(start_time: u64, end_time: u64, raise: u64,min_amount:u64,max_amount:u64,ctx: &mut TxContext) {
        let presale = PreSale<T> {
            id: object::new(ctx),
            status: 0,
            only_whitelist: false,
            raise,
            start_time,
            end_time,
            min_amount,
            max_amount,
            balance: coin::zero<T>(ctx),
            white_listed: vector::empty(),
            members: vec_map::empty(),
        };

        public_transfer(ManageCapAbility<T> {
            id: object::new(ctx),
            sale_id: object::id(&presale)
        }, tx_context::sender(ctx));

        public_share_object(presale);
    }


    fun is_whitelisted<T>(sale: &PreSale<T>, address: address): bool {
        vector::contains(&sale.white_listed, &address)
    }

    public entry fun fund<T>(sale: &mut PreSale<T>, payment: Coin<T>, clock: &Clock, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        if (sale.only_whitelist) {
            assert!(is_whitelisted(sale, sender), NOT_WHITELIST);
        };

        let current_time = clock::timestamp_ms(clock);
        assert!(current_time >= sale.start_time && current_time <= sale.end_time, NOT_STARTED);


        let amount = coin::value(&payment);
        assert!(sale.raise + amount <= sale.raise, MAX_CAP_REACHED);
        assert!(amount <= sale.max_amount, USER_MAX_CAP_REACHED);
        assert!(amount >= sale.min_amount, USER_MAX_CAP_REACHED);
        coin::join(&mut sale.balance, payment);

        if (vec_map::contains(&mut sale.members, &sender)) {
            let account_amount = vec_map::get_mut(&mut sale.members, &sender);
            assert!(*account_amount + amount <= sale.max_amount, USER_MAX_CAP_REACHED);
            *account_amount = (*account_amount + amount);
        } else {
            vec_map::insert(&mut sale.members, sender, amount);
        }
    }

    public entry fun transfer_funds<T>(
        sale: &mut PreSale<T>,
        manage: &ManageCapAbility<T>,
        recipient: address,
        ctx: &mut TxContext
    ) {
        assert!(object::id(sale) == manage.sale_id, OWNER_ONLY);

        let amount = coin::value(&sale.balance);
        let split_amount = coin::split(&mut sale.balance, amount, ctx);

        public_transfer(split_amount, recipient);
    }

    public entry fun transfer_funds_to_self<T>(
        sale: &mut PreSale<T>,
        manage: &ManageCapAbility<T>,
        ctx: &mut TxContext
    ) {
        assert!(object::id(sale) == manage.sale_id, OWNER_ONLY);

        let amount = coin::value(&sale.balance);
        let split_amount = coin::split(&mut sale.balance, amount, ctx);

        public_transfer(split_amount, tx_context::sender(ctx));
    }

    public entry fun add_white_list<T>(
        sale: &mut PreSale<T>,
        manage: &ManageCapAbility<T>,
        list: vector<address>
    ) {
        assert!(object::id(sale) == manage.sale_id, OWNER_ONLY);
        let length = vector::length(&list);
        let i = 0;
        while (i < length) {
            let address = vector::pop_back(&mut list);
            if (!is_whitelisted(sale, address)) {
                vector::push_back(&mut sale.white_listed, address);
            }
        }
    }
}
