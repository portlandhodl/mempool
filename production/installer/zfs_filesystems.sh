#!/usr/bin/env zsh

zfsCreateFilesystems()
{
    # Create datasets with proper mountpoints
    # For ZFS, dataset names should not have leading slashes, but mountpoints can
    
    # Check if ZPOOL is set
    if [ -z "${ZPOOL}" ]; then
        echo "[!] Error: No ZFS pool found. Cannot create ZFS filesystems."
        return 1
    fi
    
    echo "[*] Creating ZFS datasets on pool: ${ZPOOL}"
    
    # Create backup dataset (only if it doesn't exist)
    if ! zfs list "${ZPOOL}/backup" >/dev/null 2>&1; then
        zfs create -o mountpoint=/backup "${ZPOOL}/backup"
    else
        echo "[*] Dataset ${ZPOOL}/backup already exists, skipping creation"
    fi
    
    # Create cache dataset (only if it doesn't exist)
    if ! zfs list "${ZPOOL}/cache" >/dev/null 2>&1; then
        zfs create -o mountpoint=/var/cache/nginx "${ZPOOL}/cache"
    else
        echo "[*] Dataset ${ZPOOL}/cache already exists, skipping creation"
    fi
    
    # Create application datasets (only if they don't exist)
    # Elements dataset
    if ! zfs list "${ZPOOL}/elements" >/dev/null 2>&1; then
        zfs create -o mountpoint=${ELEMENTS_HOME} "${ZPOOL}/elements"
    else
        echo "[*] Dataset ${ZPOOL}/elements already exists, skipping creation"
    fi
    
    # Bitcoin dataset
    if ! zfs list "${ZPOOL}/bitcoin" >/dev/null 2>&1; then
        zfs create -o mountpoint=${BITCOIN_HOME} "${ZPOOL}/bitcoin"
    else
        echo "[*] Dataset ${ZPOOL}/bitcoin already exists, skipping creation"
    fi
    
    # Minfee dataset
    if ! zfs list "${ZPOOL}/minfee" >/dev/null 2>&1; then
        zfs create -o mountpoint=${MINFEE_HOME} "${ZPOOL}/minfee"
    else
        echo "[*] Dataset ${ZPOOL}/minfee already exists, skipping creation"
    fi
    
    # Electrs dataset
    if ! zfs list "${ZPOOL}/electrs" >/dev/null 2>&1; then
        zfs create -o mountpoint=${ELECTRS_HOME} "${ZPOOL}/electrs"
    else
        echo "[*] Dataset ${ZPOOL}/electrs already exists, skipping creation"
    fi
    
    # Mempool dataset
    if ! zfs list "${ZPOOL}/mempool" >/dev/null 2>&1; then
        zfs create -o mountpoint=${MEMPOOL_HOME} "${ZPOOL}/mempool"
    else
        echo "[*] Dataset ${ZPOOL}/mempool already exists, skipping creation"
    fi
    
    # MySQL dataset (special case with || true)
    if ! zfs list "${ZPOOL}/mysql" >/dev/null 2>&1; then
        zfs create -o mountpoint=${MYSQL_HOME} "${ZPOOL}/mysql" || true
    else
        echo "[*] Dataset ${ZPOOL}/mysql already exists, skipping creation"
    fi

    # Create subdatasets for Bitcoin and Elements
    zfs create -o mountpoint=${BITCOIN_ELECTRS_HOME} "${ZPOOL}/bitcoin/electrs"
    zfs create -o mountpoint=${ELEMENTS_HOME}/liquidv1 "${ZPOOL}/elements/liquidv1"
    zfs create -o mountpoint=${ELEMENTS_ELECTRS_HOME} "${ZPOOL}/elements/electrs"

    # Create socket datasets with custom ACL
    zfs create -o mountpoint=${BITCOIN_HOME}/socket "${ZPOOL}/bitcoin/socket"
    zfs create -o mountpoint=${ELEMENTS_HOME}/socket "${ZPOOL}/elements/socket"

    # Create Bitcoin network-specific datasets
    # Bitcoin Mainnet
    if [ "${BITCOIN_MAINNET_ENABLE}" = ON ];then
        for folder in chainstate indexes blocks
        do
            zfs create -o mountpoint=${BITCOIN_HOME}/${folder} "${ZPOOL}/bitcoin/${folder}"
        done
    fi

    # Bitcoin Testnet
    if [ "${BITCOIN_TESTNET_ENABLE}" = ON ];then
        zfs create -o mountpoint=${BITCOIN_TESTNET_DATA} "${ZPOOL}/bitcoin/testnet"
        for folder in chainstate indexes blocks
        do
            zfs create -o mountpoint=${BITCOIN_TESTNET_DATA}/${folder} "${ZPOOL}/bitcoin/testnet/${folder}"
        done
    fi

    # Bitcoin Testnet4
    if [ "${BITCOIN_TESTNET4_ENABLE}" = ON ];then
        zfs create -o mountpoint=${BITCOIN_TESTNET4_DATA} "${ZPOOL}/bitcoin/testnet4"
        for folder in chainstate indexes blocks
        do
            zfs create -o mountpoint=${BITCOIN_TESTNET4_DATA}/${folder} "${ZPOOL}/bitcoin/testnet4/${folder}"
        done
    fi

    # Bitcoin Signet
    if [ "${BITCOIN_SIGNET_ENABLE}" = ON ];then
        zfs create -o mountpoint=${BITCOIN_SIGNET_DATA} "${ZPOOL}/bitcoin/signet"
        for folder in chainstate indexes blocks
        do
            zfs create -o mountpoint=${BITCOIN_SIGNET_DATA}/${folder} "${ZPOOL}/bitcoin/signet/${folder}"
        done
    fi

    # Create electrs datasets for different networks
    
    # Electrs mainnet data
    if [ "${BITCOIN_MAINNET_ENABLE}" = ON ];then
        zfs create -o mountpoint=${ELECTRS_MAINNET_DATA} "${ELECTRS_MAINNET_ZPOOL}/electrs/mainnet"
        for folder in cache history txstore
        do
            zfs create -o mountpoint=${ELECTRS_MAINNET_DATA}/newindex/${folder} "${ELECTRS_MAINNET_ZPOOL}/electrs/mainnet/${folder}"
        done
    fi

    # Electrs testnet data
    if [ "${BITCOIN_TESTNET_ENABLE}" = ON ];then
        zfs create -o mountpoint=${ELECTRS_TESTNET_DATA} "${ELECTRS_TESTNET_ZPOOL}/electrs/testnet"
        for folder in cache history txstore
        do
            zfs create -o mountpoint=${ELECTRS_TESTNET_DATA}/newindex/${folder} "${ELECTRS_TESTNET_ZPOOL}/electrs/testnet/${folder}"
        done
    fi

    # Electrs testnet4 data
    if [ "${BITCOIN_TESTNET4_ENABLE}" = ON ];then
        zfs create -o mountpoint=${ELECTRS_TESTNET4_DATA} "${ELECTRS_TESTNET4_ZPOOL}/electrs/testnet4"
        for folder in cache history txstore
        do
            zfs create -o mountpoint=${ELECTRS_TESTNET4_DATA}/newindex/${folder} "${ELECTRS_TESTNET4_ZPOOL}/electrs/testnet4/${folder}"
        done
    fi

    # Electrs signet data
    if [ "${BITCOIN_SIGNET_ENABLE}" = ON ];then
        zfs create -o mountpoint=${ELECTRS_SIGNET_DATA} "${ELECTRS_SIGNET_ZPOOL}/electrs/signet"
        for folder in cache history txstore
        do
            zfs create -o mountpoint=${ELECTRS_SIGNET_DATA}/newindex/${folder} "${ELECTRS_SIGNET_ZPOOL}/electrs/signet/${folder}"
        done
    fi

    # Electrs liquid data
    if [ "${ELEMENTS_LIQUID_ENABLE}" = ON ];then
        zfs create -o mountpoint=${ELECTRS_LIQUID_DATA} "${ELECTRS_LIQUID_ZPOOL}/electrs/liquid"
        for folder in cache history txstore
        do
            zfs create -o mountpoint=${ELECTRS_LIQUID_DATA}/newindex/${folder} "${ELECTRS_LIQUID_ZPOOL}/electrs/liquid/${folder}"
        done
    fi

    # Electrs liquidtestnet data
    if [ "${ELEMENTS_LIQUIDTESTNET_ENABLE}" = ON ];then
        zfs create -o mountpoint=${ELECTRS_LIQUIDTESTNET_DATA} "${ELECTRS_LIQUIDTESTNET_ZPOOL}/electrs/liquidtestnet"
        for folder in cache history txstore
        do
            zfs create -o mountpoint=${ELECTRS_LIQUIDTESTNET_DATA}/newindex/${folder} "${ELECTRS_LIQUIDTESTNET_ZPOOL}/electrs/liquidtestnet/${folder}"
        done
    fi

    # Create Core Lightning dataset if enabled
    if [ "${CLN_INSTALL}" = ON ];then
        zfs create -o mountpoint=${CLN_HOME} "${ZPOOL}/cln"
    fi
}
