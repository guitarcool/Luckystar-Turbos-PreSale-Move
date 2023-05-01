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

    const NOT_WHITELIST: u64 = 1000;
    const NOT_STARTED: u64 = 1001;
    const MAX_CAP_REACHED: u64 = 1002;
    const OWNER_ONLY: u64 = 1003;


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
        balance: Coin<T>,
        white_listed: vector<address>,
    }


    public entry fun create_presale<T>(start_time: u64, end_time: u64, raise: u64, ctx: &mut TxContext) {
        let presale = PreSale<T> {
            id: object::new(ctx),
            status: 0,
            only_whitelist: false,
            raise: 0,
            start_time: 0,
            end_time: 0,
            balance: coin::zero<T>(ctx),
            white_listed: vector::empty(),
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

    public entry fun fund<T>(sale: &PreSale<T>, payment: Coin<T>, clock: &Clock, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        if (sale.only_whitelist) {
            assert!(is_whitelisted(sale, sender), NOT_WHITELIST);
        };

        let current_time = clock::timestamp_ms(clock);
        assert!(current_time >= sale.start_time && current_time <= sale.end_time, NOT_STARTED);

        let amount = coin::value(&payment);
        assert!(sale.raise + amount <= sale.raise, MAX_CAP_REACHED);
        coin::join(&mut sale.balance, payment);
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
        list: vector<address>,
        ctx: &mut TxContext
    ) {
        assert!(object::id(sale) == manage.sale_id, OWNER_ONLY);

    }
}
