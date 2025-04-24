#!/usr/bin/env zsh

clean_install() {
    echo "[*] Clean Install initiated - removing existing resources"
    
    # Confirm with user before proceeding
    echo "This will remove all existing datasets, users, and configurations. Are you sure? (y/n) "
    read REPLY
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "[*] Clean install aborted."
        return 1
    fi
    
    # Only kill zsh processes that are not part of the user's shell session
    echo "[*] Killing background zsh processes..."
    current_pid=$$
    current_sid=$(ps -o sid= -p $$)
    ps aux | grep zsh | grep -v grep | while read user pid rest; do
        pid=$(echo $pid | tr -d ' ')
        if [ "$pid" != "$$" ] && [ "$(ps -o sid= -p $pid)" != "$current_sid" ]; then
            kill -9 $pid 2>/dev/null || true
        fi
    done
    sleep 2
    
    # Use the ZPOOL variable that's already set in the main script
    if [ -z "${ZPOOL}" ]; then
        echo "[*] No ZFS pool selected, standard directories will be used."
    else
        echo "[*] Using ZFS pool: ${ZPOOL}"
    fi
    
    case $OS in
        FreeBSD)
            if [ ! -z "${ZPOOL}" ]; then
                echo "[*] Removing ZFS datasets..."
                
                # Stop services first
                echo "[*] Stopping services..."
                service nginx onestop 2>/dev/null || true
                service mysql-server onestop 2>/dev/null || true
                service tor onestop 2>/dev/null || true
                service bitcoin onestop 2>/dev/null || true
                
                # Destroy ZFS datasets in reverse order (children first)
                # CLN datasets
                if zfs list "${ZPOOL}/cln" >/dev/null 2>&1; then
                    echo "[*] Attempting to destroy ${ZPOOL}/cln dataset"
                    # First try to unmount if mounted
                    zfs unmount "${ZPOOL}/cln" 2>/dev/null || true
                    # Remove any snapshots
                    zfs list -t snapshot -r ${ZPOOL}/cln -H -o name 2>/dev/null | while read snap; do
                        echo "[*] Removing snapshot: $snap"
                        zfs destroy "$snap" 2>/dev/null || true
                    done
                    # Try normal destroy
                    zfs destroy -r "${ZPOOL}/cln" 2>/dev/null
                    if [ $? -ne 0 ]; then
                        echo "[!] Failed to destroy ${ZPOOL}/cln, trying with force option"
                        # Try with force option
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
                
                # Electrs datasets
                if zfs list "${ZPOOL}/electrs" >/dev/null 2>&1; then
                    echo "[*] Attempting to destroy ${ZPOOL}/electrs dataset"
                    # First try to unmount if mounted
                    zfs unmount "${ZPOOL}/electrs" 2>/dev/null || true
                    # Remove any snapshots
                    zfs list -t snapshot -r ${ZPOOL}/electrs -H -o name 2>/dev/null | while read snap; do
                        echo "[*] Removing snapshot: $snap"
                        zfs destroy "$snap" 2>/dev/null || true
                    done
                    # Try normal destroy
                    zfs destroy -r "${ZPOOL}/electrs" 2>/dev/null
                    if [ $? -ne 0 ]; then
                        echo "[!] Failed to destroy ${ZPOOL}/electrs, trying with force option"
                        # Try with force option
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
                
                # Elements datasets
                if zfs list "${ZPOOL}/elements" >/dev/null 2>&1; then
                    echo "[*] Attempting to destroy ${ZPOOL}/elements dataset"
                    # First try to unmount if mounted
                    zfs unmount "${ZPOOL}/elements" 2>/dev/null || true
                    # Remove any snapshots
                    zfs list -t snapshot -r ${ZPOOL}/elements -H -o name 2>/dev/null | while read snap; do
                        echo "[*] Removing snapshot: $snap"
                        zfs destroy "$snap" 2>/dev/null || true
                    done
                    # Try normal destroy
                    zfs destroy -r "${ZPOOL}/elements" 2>/dev/null
                    if [ $? -ne 0 ]; then
                        echo "[!] Failed to destroy ${ZPOOL}/elements, trying with force option"
                        # Try with force option
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
                
                # Bitcoin datasets (including testnet, signet, etc.)
                if zfs list "${ZPOOL}/bitcoin" >/dev/null 2>&1; then
                    echo "[*] Attempting to destroy ${ZPOOL}/bitcoin dataset"
                    # First try to unmount if mounted
                    zfs unmount "${ZPOOL}/bitcoin" 2>/dev/null || true
                    # Remove any snapshots
                    zfs list -t snapshot -r ${ZPOOL}/bitcoin -H -o name 2>/dev/null | while read snap; do
                        echo "[*] Removing snapshot: $snap"
                        zfs destroy "$snap" 2>/dev/null || true
                    done
                    # Try normal destroy
                    zfs destroy -r "${ZPOOL}/bitcoin" 2>/dev/null
                    if [ $? -ne 0 ]; then
                        echo "[!] Failed to destroy ${ZPOOL}/bitcoin, trying with force option"
                        # Try with force option
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
                
                # Minfee dataset
                if zfs list "${ZPOOL}/minfee" >/dev/null 2>&1; then
                    echo "[*] Attempting to destroy ${ZPOOL}/minfee dataset"
                    # First try to unmount if mounted
                    zfs unmount "${ZPOOL}/minfee" 2>/dev/null || true
                    # Remove any snapshots
                    zfs list -t snapshot -r ${ZPOOL}/minfee -H -o name 2>/dev/null | while read snap; do
                        echo "[*] Removing snapshot: $snap"
                        zfs destroy "$snap" 2>/dev/null || true
                    done
                    # Try normal destroy
                    zfs destroy -r "${ZPOOL}/minfee" 2>/dev/null
                    if [ $? -ne 0 ]; then
                        echo "[!] Failed to destroy ${ZPOOL}/minfee, trying with force option"
                        # Try with force option
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
                
                # Mempool dataset
                if zfs list "${ZPOOL}/mempool" >/dev/null 2>&1; then
                    echo "[*] Attempting to destroy ${ZPOOL}/mempool dataset"
                    # First try to unmount if mounted
                    zfs unmount "${ZPOOL}/mempool" 2>/dev/null || true
                    # Remove any snapshots
                    zfs list -t snapshot -r ${ZPOOL}/mempool -H -o name 2>/dev/null | while read snap; do
                        echo "[*] Removing snapshot: $snap"
                        zfs destroy "$snap" 2>/dev/null || true
                    done
                    # Try normal destroy
                    zfs destroy -r "${ZPOOL}/mempool" 2>/dev/null
                    if [ $? -ne 0 ]; then
                        echo "[!] Failed to destroy ${ZPOOL}/mempool, trying with force option"
                        # Try with force option
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
                
                # MySQL dataset
                if zfs list "${ZPOOL}/mysql" >/dev/null 2>&1; then
                    echo "[*] Attempting to destroy ${ZPOOL}/mysql dataset"
                    # First try to unmount if mounted
                    zfs unmount "${ZPOOL}/mysql" 2>/dev/null || true
                    # Remove any snapshots
                    zfs list -t snapshot -r ${ZPOOL}/mysql -H -o name 2>/dev/null | while read snap; do
                        echo "[*] Removing snapshot: $snap"
                        zfs destroy "$snap" 2>/dev/null || true
                    done
                    # Try normal destroy
                    zfs destroy -r "${ZPOOL}/mysql" 2>/dev/null
                    if [ $? -ne 0 ]; then
                        echo "[!] Failed to destroy ${ZPOOL}/mysql, trying with force option"
                        # Try with force option
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
                
                # Cache dataset
                if zfs list "${ZPOOL}/cache" >/dev/null 2>&1; then
                    echo "[*] Attempting to destroy ${ZPOOL}/cache dataset"
                    # First try to unmount if mounted
                    zfs unmount "${ZPOOL}/cache" 2>/dev/null || true
                    # Remove any snapshots
                    zfs list -t snapshot -r ${ZPOOL}/cache -H -o name 2>/dev/null | while read snap; do
                        echo "[*] Removing snapshot: $snap"
                        zfs destroy "$snap" 2>/dev/null || true
                    done
                    # Try normal destroy
                    zfs destroy -r "${ZPOOL}/cache" 2>/dev/null
                    if [ $? -ne 0 ]; then
                        echo "[!] Failed to destroy ${ZPOOL}/cache, trying with force option"
                        # Try with force option
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
                
                # Backup dataset
                if zfs list "${ZPOOL}/backup" >/dev/null 2>&1; then
                    echo "[*] Attempting to destroy ${ZPOOL}/backup dataset"
                    # First try to unmount if mounted
                    zfs unmount "${ZPOOL}/backup" 2>/dev/null || true
                    # Remove any snapshots
                    zfs list -t snapshot -r ${ZPOOL}/backup -H -o name 2>/dev/null | while read snap; do
                        echo "[*] Removing snapshot: $snap"
                        zfs destroy "$snap" 2>/dev/null || true
                    done
                    # Try normal destroy
                    zfs destroy -r "${ZPOOL}/backup" 2>/dev/null
                    if [ $? -ne 0 ]; then
                        echo "[!] Failed to destroy ${ZPOOL}/backup, trying with force option"
                        # Try with force option
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
            
            # Remove directories if they exist (for non-ZFS systems or leftover directories)
            echo "[*] Removing directories..."
            rm -rf "/backup" "${ELEMENTS_HOME}" "${BITCOIN_HOME}" "${MINFEE_HOME}" "${ELECTRS_HOME}" "${MEMPOOL_HOME}" "${MYSQL_HOME}" "${CLN_HOME}" 2>/dev/null || true
            
            # Remove users with force flag
            echo "[*] Removing users..."
            pw userdel -f "${MEMPOOL_USER}" 2>/dev/null || true
            pw userdel -f "${BITCOIN_USER}" 2>/dev/null || true
            pw userdel -f "${MINFEE_USER}" 2>/dev/null || true
            pw userdel -f "${ELEMENTS_USER}" 2>/dev/null || true
            pw userdel -f "${CLN_USER}" 2>/dev/null || true
            pw userdel -f "${CKPOOL_USER}" 2>/dev/null || true
            
            # Remove groups with force flag
            echo "[*] Removing groups..."
            pw groupdel -f "${MEMPOOL_GROUP}" 2>/dev/null || true
            pw groupdel -f "${BITCOIN_GROUP}" 2>/dev/null || true
            pw groupdel -f "${MINFEE_GROUP}" 2>/dev/null || true
            pw groupdel -f "${ELEMENTS_GROUP}" 2>/dev/null || true
            pw groupdel -f "${CLN_GROUP}" 2>/dev/null || true
            pw groupdel -f "${CKPOOL_GROUP}" 2>/dev/null || true
            
            # Clean up configuration files
            echo "[*] Cleaning up configuration files..."
            rm -f "${NGINX_CONFIGURATION}" 2>/dev/null || true
            rm -f "${TOR_CONFIGURATION}" 2>/dev/null || true
        ;;
        
        Debian)
            # Stop services first
            echo "[*] Stopping services..."
            systemctl stop nginx 2>/dev/null || true
            systemctl stop mysql 2>/dev/null || true
            systemctl stop tor 2>/dev/null || true
            systemctl stop bitcoin.service 2>/dev/null || true
            systemctl stop bitcoin-minfee.service 2>/dev/null || true
            systemctl stop bitcoin-testnet.service 2>/dev/null || true
            systemctl stop bitcoin-testnet4.service 2>/dev/null || true
            systemctl stop bitcoin-signet.service 2>/dev/null || true
            systemctl stop elements-liquid.service 2>/dev/null || true
            systemctl stop elements-liquidtestnet.service 2>/dev/null || true
            
            # Remove directories
            echo "[*] Removing directories..."
            rm -rf "/backup" "${ELEMENTS_HOME}" "${BITCOIN_HOME}" "${MINFEE_HOME}" "${ELECTRS_HOME}" "${MEMPOOL_HOME}" "${MYSQL_HOME}" "${CLN_HOME}" 2>/dev/null || true
            
            # Remove users with force flag
            echo "[*] Removing users..."
            userdel -f "${MEMPOOL_USER}" 2>/dev/null || true
            userdel -f "${BITCOIN_USER}" 2>/dev/null || true
            userdel -f "${MINFEE_USER}" 2>/dev/null || true
            userdel -f "${ELEMENTS_USER}" 2>/dev/null || true
            userdel -f "${CLN_USER}" 2>/dev/null || true
            userdel -f "${CKPOOL_USER}" 2>/dev/null || true
            
            # Remove groups with force flag
            echo "[*] Removing groups..."
            groupdel -f "${MEMPOOL_GROUP}" 2>/dev/null || true
            groupdel -f "${BITCOIN_GROUP}" 2>/dev/null || true
            groupdel -f "${MINFEE_GROUP}" 2>/dev/null || true
            groupdel -f "${ELEMENTS_GROUP}" 2>/dev/null || true
            groupdel -f "${CLN_GROUP}" 2>/dev/null || true
            groupdel -f "${CKPOOL_GROUP}" 2>/dev/null || true
            
            # Clean up configuration files
            echo "[*] Cleaning up configuration files..."
            rm -f "${NGINX_CONFIGURATION}" 2>/dev/null || true
            rm -f "${TOR_CONFIGURATION}" 2>/dev/null || true
            
            # Remove systemd service files
            echo "[*] Removing systemd service files..."
            rm -f "${DEBIAN_SERVICE_HOME}/bitcoin.service" 2>/dev/null || true
            rm -f "${DEBIAN_SERVICE_HOME}/bitcoin-minfee.service" 2>/dev/null || true
            rm -f "${DEBIAN_SERVICE_HOME}/bitcoin-testnet.service" 2>/dev/null || true
            rm -f "${DEBIAN_SERVICE_HOME}/bitcoin-testnet4.service" 2>/dev/null || true
            rm -f "${DEBIAN_SERVICE_HOME}/bitcoin-signet.service" 2>/dev/null || true
            rm -f "${DEBIAN_SERVICE_HOME}/elements-liquid.service" 2>/dev/null || true
            rm -f "${DEBIAN_SERVICE_HOME}/elements-liquidtestnet.service" 2>/dev/null || true
            
            # Reload systemd
            systemctl daemon-reload
        ;;
    esac
    
    # Clean up MySQL databases
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

# Make the function available to the main script
# Use export -f for bash compatibility or typeset -fx for zsh
if [ -n "$BASH_VERSION" ]; then
    export -f clean_install
else
    typeset -f clean_install
fi
