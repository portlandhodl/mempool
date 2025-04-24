#!/usr/bin/env zsh

# clean_install: Performs a complete cleanup of mempool-related resources on FreeBSD
# - Removes all services, datasets, users, and configurations
# - Handles graceful shutdown of running services
# - Ensures clean removal of all components
clean_install() {
    echo "[*] Clean Install initiated - removing existing resources"
    echo "This will remove all existing datasets, users, and configurations. Are you sure? (y/n) "
    read REPLY
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "[*] Clean install aborted."
        return 1
    fi
    
    # Kill terminal multiplexer sessions to prevent resource locks
    echo "[*] Killing screen and tmux sessions..."
    screen -ls | grep -o '[0-9]*\.[^[:space:]]*' | while read session; do
        screen -S "$session" -X quit 2>/dev/null || true
    done
    pkill -9 screen 2>/dev/null || true
    
    tmux list-sessions 2>/dev/null | cut -d: -f1 | while read session; do
        tmux kill-session -t "$session" 2>/dev/null || true
    done
    pkill -9 tmux 2>/dev/null || true
    sleep 2
    if [ -z "${ZPOOL}" ]; then
        echo "[*] No ZFS pool selected, standard directories will be used."
    else
        echo "[*] Using ZFS pool: ${ZPOOL}"
    fi
    
    # FreeBSD cleanup with ZFS datasets
    if [ ! -z "${ZPOOL}" ]; then
        echo "[*] Removing ZFS datasets..."
        echo "[*] Stopping services..."
        service nginx onestop 2>/dev/null || true
        service mysql-server onestop 2>/dev/null || true
        service tor onestop 2>/dev/null || true
        service bitcoin onestop 2>/dev/null || true
        if zfs list "${ZPOOL}/cln" >/dev/null 2>&1; then
            echo "[*] Attempting to destroy ${ZPOOL}/cln dataset"
            zfs unmount "${ZPOOL}/cln" 2>/dev/null || true
            zfs list -t snapshot -r ${ZPOOL}/cln -H -o name 2>/dev/null | while read snap; do
                echo "[*] Removing snapshot: $snap"
                zfs destroy "$snap" 2>/dev/null || true
            done
            zfs destroy -r "${ZPOOL}/cln" 2>/dev/null
            if [ $? -ne 0 ]; then
                echo "[!] Failed to destroy ${ZPOOL}/cln, trying with force option"
                zfs destroy -rf "${ZPOOL}/cln" 2>/dev/null
                if [ $? -ne 0 ]; then
                    echo "[!] Failed to destroy ${ZPOOL}/cln even with force option"
                    echo "[!] You may need to manually remove this dataset with: zfs destroy -rf ${ZPOOL}/cln"
                else
                    echo "[*] Successfully destroyed ${ZPOOL}/cln with force option"
                fi
            else
                echo "[*] Successfully destroyed ${ZPOOL}/cln"
            fi
        fi
        if zfs list "${ZPOOL}/electrs" >/dev/null 2>&1; then
            echo "[*] Attempting to destroy ${ZPOOL}/electrs dataset"
            zfs unmount "${ZPOOL}/electrs" 2>/dev/null || true
            zfs list -t snapshot -r ${ZPOOL}/electrs -H -o name 2>/dev/null | while read snap; do
                echo "[*] Removing snapshot: $snap"
                zfs destroy "$snap" 2>/dev/null || true
            done
            zfs destroy -r "${ZPOOL}/electrs" 2>/dev/null
            if [ $? -ne 0 ]; then
                echo "[!] Failed to destroy ${ZPOOL}/electrs, trying with force option"
                zfs destroy -rf "${ZPOOL}/electrs" 2>/dev/null
                if [ $? -ne 0 ]; then
                    echo "[!] Failed to destroy ${ZPOOL}/electrs even with force option"
                    echo "[!] You may need to manually remove this dataset with: zfs destroy -rf ${ZPOOL}/electrs"
                else
                    echo "[*] Successfully destroyed ${ZPOOL}/electrs with force option"
                fi
            else
                echo "[*] Successfully destroyed ${ZPOOL}/electrs"
            fi
        fi
        if zfs list "${ZPOOL}/elements" >/dev/null 2>&1; then
            echo "[*] Attempting to destroy ${ZPOOL}/elements dataset"
            zfs unmount "${ZPOOL}/elements" 2>/dev/null || true
            zfs list -t snapshot -r ${ZPOOL}/elements -H -o name 2>/dev/null | while read snap; do
                echo "[*] Removing snapshot: $snap"
                zfs destroy "$snap" 2>/dev/null || true
            done
            zfs destroy -r "${ZPOOL}/elements" 2>/dev/null
            if [ $? -ne 0 ]; then
                echo "[!] Failed to destroy ${ZPOOL}/elements, trying with force option"
                zfs destroy -rf "${ZPOOL}/elements" 2>/dev/null
                if [ $? -ne 0 ]; then
                    echo "[!] Failed to destroy ${ZPOOL}/elements even with force option"
                    echo "[!] You may need to manually remove this dataset with: zfs destroy -rf ${ZPOOL}/elements"
                else
                    echo "[*] Successfully destroyed ${ZPOOL}/elements with force option"
                fi
            else
                echo "[*] Successfully destroyed ${ZPOOL}/elements"
            fi
        fi
        if zfs list "${ZPOOL}/bitcoin" >/dev/null 2>&1; then
            echo "[*] Attempting to destroy ${ZPOOL}/bitcoin dataset"
            zfs unmount "${ZPOOL}/bitcoin" 2>/dev/null || true
            zfs list -t snapshot -r ${ZPOOL}/bitcoin -H -o name 2>/dev/null | while read snap; do
                echo "[*] Removing snapshot: $snap"
                zfs destroy "$snap" 2>/dev/null || true
            done
            zfs destroy -r "${ZPOOL}/bitcoin" 2>/dev/null
            if [ $? -ne 0 ]; then
                echo "[!] Failed to destroy ${ZPOOL}/bitcoin, trying with force option"
                zfs destroy -rf "${ZPOOL}/bitcoin" 2>/dev/null
                if [ $? -ne 0 ]; then
                    echo "[!] Failed to destroy ${ZPOOL}/bitcoin even with force option"
                    echo "[!] You may need to manually remove this dataset with: zfs destroy -rf ${ZPOOL}/bitcoin"
                else
                    echo "[*] Successfully destroyed ${ZPOOL}/bitcoin with force option"
                fi
            else
                echo "[*] Successfully destroyed ${ZPOOL}/bitcoin"
            fi
        fi
        if zfs list "${ZPOOL}/minfee" >/dev/null 2>&1; then
            echo "[*] Attempting to destroy ${ZPOOL}/minfee dataset"
            zfs unmount "${ZPOOL}/minfee" 2>/dev/null || true
            zfs list -t snapshot -r ${ZPOOL}/minfee -H -o name 2>/dev/null | while read snap; do
                echo "[*] Removing snapshot: $snap"
                zfs destroy "$snap" 2>/dev/null || true
            done
            zfs destroy -r "${ZPOOL}/minfee" 2>/dev/null
            if [ $? -ne 0 ]; then
                echo "[!] Failed to destroy ${ZPOOL}/minfee, trying with force option"
                zfs destroy -rf "${ZPOOL}/minfee" 2>/dev/null
                if [ $? -ne 0 ]; then
                    echo "[!] Failed to destroy ${ZPOOL}/minfee even with force option"
                    echo "[!] You may need to manually remove this dataset with: zfs destroy -rf ${ZPOOL}/minfee"
                else
                    echo "[*] Successfully destroyed ${ZPOOL}/minfee with force option"
                fi
            else
                echo "[*] Successfully destroyed ${ZPOOL}/minfee"
            fi
        fi
        
        if zfs list "${ZPOOL}/mempool" >/dev/null 2>&1; then
            echo "[*] Attempting to destroy ${ZPOOL}/mempool dataset"
            zfs unmount "${ZPOOL}/mempool" 2>/dev/null || true
            zfs list -t snapshot -r ${ZPOOL}/mempool -H -o name 2>/dev/null | while read snap; do
                echo "[*] Removing snapshot: $snap"
                zfs destroy "$snap" 2>/dev/null || true
            done
            zfs destroy -r "${ZPOOL}/mempool" 2>/dev/null
            if [ $? -ne 0 ]; then
                echo "[!] Failed to destroy ${ZPOOL}/mempool, trying with force option"
                zfs destroy -rf "${ZPOOL}/mempool" 2>/dev/null
                if [ $? -ne 0 ]; then
                    echo "[!] Failed to destroy ${ZPOOL}/mempool even with force option"
                    echo "[!] You may need to manually remove this dataset with: zfs destroy -rf ${ZPOOL}/mempool"
                else
                    echo "[*] Successfully destroyed ${ZPOOL}/mempool with force option"
                fi
            else
                echo "[*] Successfully destroyed ${ZPOOL}/mempool"
            fi
        fi
        
        if zfs list "${ZPOOL}/mysql" >/dev/null 2>&1; then
            echo "[*] Attempting to destroy ${ZPOOL}/mysql dataset"
            zfs unmount "${ZPOOL}/mysql" 2>/dev/null || true
            zfs list -t snapshot -r ${ZPOOL}/mysql -H -o name 2>/dev/null | while read snap; do
                echo "[*] Removing snapshot: $snap"
                zfs destroy "$snap" 2>/dev/null || true
            done
            zfs destroy -r "${ZPOOL}/mysql" 2>/dev/null
            if [ $? -ne 0 ]; then
                echo "[!] Failed to destroy ${ZPOOL}/mysql, trying with force option"
                zfs destroy -rf "${ZPOOL}/mysql" 2>/dev/null
                if [ $? -ne 0 ]; then
                    echo "[!] Failed to destroy ${ZPOOL}/mysql even with force option"
                    echo "[!] You may need to manually remove this dataset with: zfs destroy -rf ${ZPOOL}/mysql"
                else
                    echo "[*] Successfully destroyed ${ZPOOL}/mysql with force option"
                fi
            else
                echo "[*] Successfully destroyed ${ZPOOL}/mysql"
            fi
        fi
        
        if zfs list "${ZPOOL}/cache" >/dev/null 2>&1; then
            echo "[*] Attempting to destroy ${ZPOOL}/cache dataset"
            zfs unmount "${ZPOOL}/cache" 2>/dev/null || true
            zfs list -t snapshot -r ${ZPOOL}/cache -H -o name 2>/dev/null | while read snap; do
                echo "[*] Removing snapshot: $snap"
                zfs destroy "$snap" 2>/dev/null || true
            done
            zfs destroy -r "${ZPOOL}/cache" 2>/dev/null
            if [ $? -ne 0 ]; then
                echo "[!] Failed to destroy ${ZPOOL}/cache, trying with force option"
                zfs destroy -rf "${ZPOOL}/cache" 2>/dev/null
                if [ $? -ne 0 ]; then
                    echo "[!] Failed to destroy ${ZPOOL}/cache even with force option"
                    echo "[!] You may need to manually remove this dataset with: zfs destroy -rf ${ZPOOL}/cache"
                else
                    echo "[*] Successfully destroyed ${ZPOOL}/cache with force option"
                fi
            else
                echo "[*] Successfully destroyed ${ZPOOL}/cache"
            fi
        fi
        
        if zfs list "${ZPOOL}/backup" >/dev/null 2>&1; then
            echo "[*] Attempting to destroy ${ZPOOL}/backup dataset"
            zfs unmount "${ZPOOL}/backup" 2>/dev/null || true
            zfs list -t snapshot -r ${ZPOOL}/backup -H -o name 2>/dev/null | while read snap; do
                echo "[*] Removing snapshot: $snap"
                zfs destroy "$snap" 2>/dev/null || true
            done
            zfs destroy -r "${ZPOOL}/backup" 2>/dev/null
            if [ $? -ne 0 ]; then
                echo "[!] Failed to destroy ${ZPOOL}/backup, trying with force option"
                zfs destroy -rf "${ZPOOL}/backup" 2>/dev/null
                if [ $? -ne 0 ]; then
                    echo "[!] Failed to destroy ${ZPOOL}/backup even with force option"
                    echo "[!] You may need to manually remove this dataset with: zfs destroy -rf ${ZPOOL}/backup"
                else
                    echo "[*] Successfully destroyed ${ZPOOL}/backup with force option"
                fi
            else
                echo "[*] Successfully destroyed ${ZPOOL}/backup"
            fi
        fi
    fi
    
    # Clean up standard directories and files
    echo "[*] Removing directories..."
    rm -rf "/backup" "${ELEMENTS_HOME}" "${BITCOIN_HOME}" "${MINFEE_HOME}" "${ELECTRS_HOME}" "${MEMPOOL_HOME}" "${MYSQL_HOME}" "${CLN_HOME}" 2>/dev/null || true
    
    # Remove users and groups
    source "${SCRIPT_DIR}/installer/remove_users_groups.sh"
    remove_users_groups
    
    echo "[*] Cleaning up configuration files..."
    rm -f "${NGINX_CONFIGURATION}" 2>/dev/null || true
    rm -f "${TOR_CONFIGURATION}" 2>/dev/null || true
    
    # Clean up all MySQL databases
    echo "[*] Cleaning up MySQL databases..."
    mysql -e "DROP DATABASE IF EXISTS mempool;" 2>/dev/null || true
    mysql -e "DROP DATABASE IF EXISTS mempool_testnet;" 2>/dev/null || true
    mysql -e "DROP DATABASE IF EXISTS mempool_testnet4;" 2>/dev/null || true
    mysql -e "DROP DATABASE IF EXISTS mempool_signet;" 2>/dev/null || true
    mysql -e "DROP DATABASE IF EXISTS mempool_mainnet_lightning;" 2>/dev/null || true
    mysql -e "DROP DATABASE IF EXISTS mempool_testnet_lightning;" 2>/dev/null || true
    mysql -e "DROP DATABASE IF EXISTS mempool_signet_lightning;" 2>/dev/null || true
    mysql -e "DROP DATABASE IF EXISTS mempool_liquid;" 2>/dev/null || true
    mysql -e "DROP DATABASE IF EXISTS mempool_liquidtestnet;" 2>/dev/null || true
    
    echo "[*] Clean install completed. Ready for fresh installation."
}

# Export function for shell compatibility
if [ -n "$BASH_VERSION" ]; then
    export -f clean_install
else
    typeset -f clean_install
fi
