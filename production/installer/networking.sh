##################################################
##### P2P / RPC / HTTP network communication #####
##################################################

# used for firewall configuration
BITCOIN_MAINNET_P2P_HOST=127.0.0.1
BITCOIN_MAINNET_P2P_PORT=8333
# used for RPC communication
BITCOIN_MAINNET_RPC_HOST=127.0.0.1
BITCOIN_MAINNET_RPC_PORT=8332
# generate random hex string
BITCOIN_RPC_USER=$(head -150 /dev/urandom | ${MD5} | awk '{print $1}')
BITCOIN_RPC_PASS=$(head -150 /dev/urandom | ${MD5} | awk '{print $1}')

# used for firewall configuration
BITCOIN_TESTNET_P2P_HOST=127.0.0.1
BITCOIN_TESTNET_P2P_PORT=18333
# used for RPC communication
BITCOIN_TESTNET_RPC_HOST=127.0.0.1
BITCOIN_TESTNET_RPC_PORT=18332

# used for firewall configuration
BITCOIN_TESTNET4_P2P_HOST=127.0.0.1
BITCOIN_TESTNET4_P2P_PORT=48333
# used for RPC communication
BITCOIN_TESTNET4_RPC_HOST=127.0.0.1
BITCOIN_TESTNET4_RPC_PORT=48332

# used for firewall configuration
BITCOIN_SIGNET_P2P_HOST=127.0.0.1
BITCOIN_SIGNET_P2P_PORT=18333
# used for RPC communication
BITCOIN_SIGNET_RPC_HOST=127.0.0.1
BITCOIN_SIGNET_RPC_PORT=18332
# generate random hex string
BITCOIN_SIGNET_RPC_USER=$(head -150 /dev/urandom | ${MD5} | awk '{print $1}')
BITCOIN_SIGNET_RPC_PASS=$(head -150 /dev/urandom | ${MD5} | awk '{print $1}')

# used for firewall configuration
ELEMENTS_LIQUID_P2P_HOST=127.0.0.1
ELEMENTS_LIQUID_P2P_PORT=7042
# used for RPC communication
ELEMENTS_LIQUID_RPC_HOST=127.0.0.1
ELEMENTS_LIQUID_RPC_PORT=7041
# generate random hex string
ELEMENTS_RPC_USER=$(head -150 /dev/urandom | ${MD5} | awk '{print $1}')
ELEMENTS_RPC_PASS=$(head -150 /dev/urandom | ${MD5} | awk '{print $1}')

# set either socket or TCP host/port, not both
#ELECTRS_MAINNET_HTTP_SOCK=/tmp/bitcoin.mainnet.electrs
ELECTRS_MAINNET_HTTP_HOST=127.0.0.1
ELECTRS_MAINNET_HTTP_PORT=3000

# set either socket or TCP host/port, not both
#ELECTRS_LIQUID_HTTP_SOCK=/tmp/elements.liquid.electrs
ELECTRS_LIQUID_HTTP_HOST=127.0.0.1
ELECTRS_LIQUID_HTTP_PORT=3001

# set either socket or TCP host/port, not both
#ELECTRS_TESTNET_HTTP_SOCK=/tmp/bitcoin.testnet.electrs
ELECTRS_TESTNET_HTTP_HOST=127.0.0.1
ELECTRS_TESTNET_HTTP_PORT=3002

# set either socket or TCP host/port, not both
#ELECTRS_TESTNET4_HTTP_SOCK=/tmp/bitcoin.testnet4.electrs
ELECTRS_TESTNET4_HTTP_HOST=127.0.0.1
ELECTRS_TESTNET4_HTTP_PORT=3005

# set either socket or TCP host/port, not both
#ELECTRS_SIGNET_HTTP_SOCK=/tmp/bitcoin.testnet.electrs
ELECTRS_SIGNET_HTTP_HOST=127.0.0.1
ELECTRS_SIGNET_HTTP_PORT=3003

# set either socket or TCP host/port, not both
#ELECTRS_LIQUIDTESTNET_HTTP_SOCK=/tmp/bitcoin.testnet.electrs
ELECTRS_LIQUIDTESTNET_HTTP_HOST=127.0.0.1
ELECTRS_LIQUIDTESTNET_HTTP_PORT=3004

# set either socket or TCP host/port, not both
#MEMPOOL_MAINNET_HTTP_SOCK=/tmp/bitcoin.mainnet.mempool
MEMPOOL_MAINNET_HTTP_HOST=127.0.0.1
MEMPOOL_MAINNET_HTTP_PORT=8999

# set either socket or TCP host/port, not both
#MEMPOOL_LIQUID_HTTP_SOCK=/tmp/elements.liquid.mempool
MEMPOOL_LIQUID_HTTP_HOST=127.0.0.1
MEMPOOL_LIQUID_HTTP_PORT=8998

# set either socket or TCP host/port, not both
#MEMPOOL_TESTNET_HTTP_SOCK=/tmp/bitcoin.testnet.mempool
MEMPOOL_TESTNET_HTTP_HOST=127.0.0.1
MEMPOOL_TESTNET_HTTP_PORT=8997

# set either socket or TCP host/port, not both
#MEMPOOL_TESTNET4_HTTP_SOCK=/tmp/bitcoin.testnet.mempool
MEMPOOL_TESTNET4_HTTP_HOST=127.0.0.1
MEMPOOL_TESTNET4_HTTP_PORT=8990

# set either socket or TCP host/port, not both
#MEMPOOL_SIGNET_HTTP_SOCK=/tmp/bitcoin.bisq.mempool
MEMPOOL_SIGNET_HTTP_HOST=127.0.0.1
MEMPOOL_SIGNET_HTTP_PORT=8995

# set either socket or TCP host/port, not both
#MEMPOOL_LIQUIDTESTNET_HTTP_SOCK=/tmp/bitcoin.bisq.mempool
MEMPOOL_LIQUIDTESTNET_HTTP_HOST=127.0.0.1
MEMPOOL_LIQUIDTESTNET_HTTP_PORT=8994

# set CKPool bitcoin mainnet port
CKPOOL_MAINNET_STRATUM_HOST=127.0.0.1
CKPOOL_MAINNET_STRATUM_PORT=3333

# set CKPool bitcoin mainnet port
CKPOOL_TESTNET_STRATUM_HOST=127.0.0.1
CKPOOL_TESTNET_STRATUM_PORT=3334

# set CKPool bitcoin mainnet port
CKPOOL_TESTNET4_STRATUM_HOST=127.0.0.1
CKPOOL_TESTNET4_STRATUM_PORT=3335
