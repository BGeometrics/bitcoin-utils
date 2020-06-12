#/bin/bash

VERSION=0.20.0
PATH_BITCOIN=/var/lib/bitcoin
PATH_BITCOIN_INSTALL=/usr/bin
USER_BITCOIN=bitcoin
PROCESS_DEP_BITCOIN="bitcoind lnd rtl btc-rpc-explorer"

if [ -n "$1" ]; then
    VERSION=$1
fi

systemctl stop $PROCESS_DEP_BITCOIN
su -c "wget https://bitnodes.io/install-full-node.sh" $USER_BITCOIN
su -c "sed -i "s/VERSION=.*/VERSION=$VERSION/g" install-full-node.sh" $USER_BITCOIN
su -c "bash install-full-node.sh" $USER_BITCOIN
su -c "$PATH_BITCOIN/bitcoin-core/bin/stop.sh" $USER_BITCOIN
install -m 0755 -o root -g root -t $PATH_BITCOIN_INSTALL $PATH_BITCOIN/bitcoin-core/bin/bitcoin*
systemctl start $PROCESS_DEP_BITCOIN
rm -fr $PATH_BITCOIN/bitcoin-core/
rm -f install-full-node.sh
$PATH_BITCOIN_INSTALL/bitcoind --version | grep version

