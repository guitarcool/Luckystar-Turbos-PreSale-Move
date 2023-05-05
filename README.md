# Luckystar-Turbos-PreSale

TurbosStar

# testnet

set -x PKG 0xf78a9799514c7a1c4d21d414f15011a7fcc0cd7a64a452d8721d73cfcbc36f28


create
```shell
sui client call --package $PKG --module ido --function create_presale  --gas-budget 30000000 --type-args $COIN::sui::SUI --args 
1683180771000 1685859171000 1000000000000000 1000000000 1000000000
```

buy
```shell
sui client call --package 0x39700181b1dcf4bf4f7b1fa596a235823ce0d1a041a71a71dab03b7c08957c0d --module ido --function fund --gas-budg
et 10000000 --type-args 0x6f1bbcf59d4b34c5c244b8e386a8e798e040cb229ce07d60b79a9c6e8f79518f::sui::SUI --args 0x88fad4959f1b5f752ea88c68
d161d8535b2a9f1680befef1705a92cd7abab83d 0x35b15eb250f35918ea9ad6d22b54065440fd788ce496ec9ffc30c6e4619f4095 0x6
```


create_claim
```shell
sui client call --package $PKG --module claim --function create_claim  --gas-budget 10000000 --type-args $COIN::sui::SUI --args 0x26
5b7e31facfc879e5ac826d0d88ffa4d047ad926426080cdd721f1eca8feecd 1683180771000 1685859171000
```

add_list
```shell
sui client call --package $PKG --module claim --function add_wait_claim_list  --gas-budget 10000000 --type-args $COIN::sui::SUI --ar
gs 0x7f43095b23f466ff5f193a28fcb307d2cb6e07bc8900bfbd8a81c3b303ecce32 0xae1bb744ca30cc3119f48ec82a04c3d92a68eda53e337beaf24bb5596afb49
32 [0x39700181b1dcf4bf4f7b1fa596a235823ce0d1a041a71a71dab03b7c08957c0d,0x1128210d2e0d2b666be9aba2f72c2f7d71e0c5c283814bdd8977a41c78b65
93c] [10000000000000,10000000000000]
```

claim
```shell

```