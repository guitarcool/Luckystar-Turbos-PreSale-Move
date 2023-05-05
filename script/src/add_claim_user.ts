import {
  JsonRpcProvider,
  Connection,
  Ed25519Keypair,
  RawSigner,
  isValidSuiAddress,
  TransactionBlock,
  bcs,
} from "@mysten/sui.js";

let w = [
  {
    address:
      "0x2248c3a8a8fb6fd0810f984016fa4d6542e1cceaf8484a6bdf97a291a8fb2028",
    amount: 1000000,
  },
  {
    address:
      "0x2248c3a8a8fb6fd0810f984016fa4d6542e1cceaf8484a6bdf97a291a8fb2028",
    amount: 1000000,
  },
  {
    address:
      "0x2248c3a8a8fb6fd0810f984016fa4d6542e1cceaf8484a6bdf97a291a8fb2028",
    amount: 1000000,
  },
  {
    address:
      "0x2248c3a8a8fb6fd0810f984016fa4d6542e1cceaf8484a6bdf97a291a8fb2028",
    amount: 1000000,
  },
];

let add_claim_list = async (vec_address: string[], vec_amount: number[]) => {
  if (vec_address.length > 500) {
    console.log("too much address to check");
    return;
  }

  const connection = new Connection({
    fullnode: "https://fullnode.testnet.sui.io:443",
    faucet: "https://faucet.devnet.sui.io/gas",
  });

  const keypair = Ed25519Keypair.deriveKeypair("");

  const pkg =
    "0xa4ad1545666eb4cd3d0d284711a2598f46afb5afc801c0209c805f701952e4be";
  const pool =
    "0xa9b5a71109b9b498f240f9a81e584030de00ea745a8b651873da909890fa3549";
  const admincap =
    "0x896ffb77a6c651cdaea5866a50d629fd6453587917b186a478a3d91c74792fab";

  const provider = new JsonRpcProvider(connection);
  const signer = new RawSigner(keypair, provider);

  const txBlock = new TransactionBlock();
  txBlock.setGasBudget(1000000000);
  const max_pure_argument_size = 16 * 1024;
  const vec_address_bytes = bcs
    .ser("vector<address>", vec_address, { maxSize: max_pure_argument_size })
    .toBytes();

  const vec_amount_bytes = bcs
    .ser("vector<u64>", vec_amount, { maxSize: max_pure_argument_size })
    .toBytes();

  txBlock.moveCall({
    target: `${pkg}::claim::add_wait_claim_list`,
    arguments: [
      txBlock.object(pool),
      txBlock.object(admincap),
      txBlock.pure(vec_address_bytes),
      txBlock.pure(vec_amount_bytes),
    ],
    typeArguments: ["0x2::sui::SUI"],
  });

  const result = await signer.signAndExecuteTransactionBlock({
    transactionBlock: txBlock,
    options: {
      showEffects: true,
      showObjectChanges: true,
    },
  });

  console.log({ result });
};

let main = async () => {
  let round = Math.ceil(w.length / 500);

  let i = 0;
  while (i < round) {
    let wl: string[] = [];
    let amounts: number[] = [];

    w.slice(i * 500, (i + 1) * 500).map((claim_user) => {
      if (isValidSuiAddress(claim_user.address)) {
        wl.push(claim_user.address);
        amounts.push(claim_user.amount);
      }
    });

    await add_claim_list(wl, amounts);
    i++;
  }
};

main();
