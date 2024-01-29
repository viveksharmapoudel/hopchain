# Wasm-08 Helper Script

## Requirements

- jq
- go
- goloop

# Run Chain Locally

## Icon Chain

Run icon chain locally and make sure that these two address has some balance in it:

balance is in icon_godwallet.json
run goloop locally and make sure you have balance in your wallet:

```
GodWallet: hxb6b5791be0b5ef67063b3c10b840fb81514db2fd
MinterWallet: hxac1f0b75d2c05692fdea027fdd0d8475650c72d6
```

## Centauri Chain

Clone centauri chain repo from github:

```
git@github.com:ComposableFi/composable-cosmos.git
```

Change the following lines for admin authority adding lightclient contract and adding relayer should go through governance proposal or admin authority access:

```
file: apps/keepers/keepers.go#L91
to the centaurid address you have access.


file: app/keepers/keepers.go#L230
from:
govModuleAuthority := authtypes.NewModuleAddress(govtypes.ModuleName).String()
to:
govModuleAuthority := authorityAddress

```

One of the address that you can generate is :

```
centauri1g5r2vmnp6lta9cpst4lzc4syy3kcj2ljte3tlh
```

Corresponding to mnemonics:

```
taste shoot adapt slow truly grape gift need suggest midnight burger horn whisper hat vast aspect exit scorpion jewel axis great area awful blind
```

If you want to run centauri chain in docker you can below command:

```
docker-compose up -d
```

Or, if you want to use this script, which will run centauri-testnode.sh script and 'centauri1g5r2vmnp6lta9cpst4lzc4syy3kcj2ljte3tlh' wallet will have some balance:

```
make start-centauri
```

# Setting up constants

File const.sh contains related to chain and incase of icon IBC contract directory, edit those before proceeding. Most of the constants are self explainatory.

# Deploying iconLight client on centauri chain

Run following command to deploy centauri chain locally:

```
make centauri-native-ready
```

note: IBC donot need to be deployed on centauri

# Deploy IBC on ICON

IBC contract are in [ibc-integration repo](https://github.com/icon-project/ibc-integration). Checkout `808-investigate-commitment-prefix-usage-in-ibc-java` branch and build contract using command:

```
./scripts/optimize-jar.sh
```

Similarly, ICS20 apps are build in a [forked repo](https://github.com/sdpisreddevil/IBC-Integration) and branch `build-separate-ics20-transfer`, clone the fork repo, build the jar and update the [const.sh](const.sh) file:

Now run following command for the complete setup:

```
make icon-ibc-ready
```

# Setting up relay:

Relayer code is in [relayer repo](https://github.com/icon-project/IBC-relay) branch `integrate-wasm-08`.

```
make update-config
```

note: make sure the centauri wallet that is used in relay should have authority access. I would suggest to add key on the relay using the same mnemonic.

## Assumption-Made:

Relay registers the ics20 light client on the name `ics08-tendermint`.

## Creating client, connection and channel

### Create-client

```
rly tx clients centauri-icon --client-tp "5040m" --src-wasm-code-id 3d2194afeaafca671c55c8dacdb4f3e318e12061a69f1dbeb98317784a6da319 --override -d
```

note: make sure to change the src-wasm-code-id if you change the cw_wasm_light_client_icon.wasm. In order to findout the code-id run this query.

```
centaurid query 08-wasm all-wasm-code
```
