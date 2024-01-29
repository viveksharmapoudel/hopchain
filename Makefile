start-centauri:
	./centauri.sh chain-start

centauri-native-ready:
	./centauri.sh deploy-wasm

icon-ibc:
	./icon.sh setup

icon-ibc-ready:
   ./icon.sh setup
   ./icon.sh ready-ics20

update-config:
   ./cfg.update.sh

