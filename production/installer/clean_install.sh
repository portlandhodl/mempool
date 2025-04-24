#!/usr/bin/env zsh
# Function for clean install - removes existing mempool.space installation

clean_install() {
    echo "[*] Clean Install initiated - removing existing resources"
    
    # Confirm with user before proceeding
    echo "This will remove all existing datasets, users, and configurations. Are you sure? (y/n) "
    read REPLY
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "[*] Clean install aborted."
        return 1
    fi
    
    # Check for ZFS pools and let user select one if they exist
    if command -v zpool &> /dev/null; then
        # Get list of available zpools
        AVAILABLE_ZPOOLS=$(zpool list -H -o name 2>/dev/null)
        
        if [ -z "$AVAILABLE_ZPOOLS" ]; then
            echo "[!] No ZFS pools found on this system. ZFS features will not be available."
            ZPOOL=""
        else
            echo "[*] Available ZFS pools:"
            # Create an array of zpools
            ZPOOL_ARRAY=()
            i=1
            while IFS= read -r pool; do
                echo "  $i) $pool"
                ZPOOL_ARRAY+=("$pool")
                ((i++))
            done <<< "$AVAILABLE_ZPOOLS"
            
            # Add option to not use ZFS
            echo "  $i) Don't use ZFS"
            
            # Ask user to select a pool
            echo -n "Select a ZFS pool to use (1-$i): "
            read POOL_SELECTION
            
            # Validate selection
            if [[ "$POOL_SELECTION" =~ ^[0-9]+$ ]] && [ "$POOL_SELECTION" -ge 1 ] && [ "$POOL_SELECTION" -le "$i" ]; then
                if [ "$POOL_SELECTION" -eq "$i" ]; then
                    # User selected not to use ZFS
                    echo "[*] ZFS will not be used for this installation."
                    ZPOOL=""
                else
                    # User selected a valid pool
                    ZPOOL="${ZPOOL_ARRAY[$((POOL_SELECTION-1))]}"
                    echo "[*] Using ZFS pool: $ZPOOL"
                fi
            else
                echo "[!] Invalid selection. ZFS will not be used."
                ZPOOL=""
            fi
        fi
    else
        echo "[!] ZFS is not installed on this system. ZFS features will not be available."
        ZPOOL=""
    fi
    
    case $OS in
        FreeBSD)
            if [ ! -z "${ZPOOL}" ]; then
                echo "[*] Removing ZFS datasets..."
                
                # Stop services first
                echo "[*] Stopping services..."
                service nginx stop 2>/dev/null || true
                service mysql-server stop 2>/dev/null || true
                service tor stop 2>/dev/null || true
                service bitcoin stop 2>/dev/null || true
                
                # Destroy ZFS datasets in reverse order (children first)
                # CLN datasets
                if zfs list "${ZPOOL}/cln" >/dev/null 2>&1; then
                    zfs destroy -r "${ZPOOL}/cln" 2>/dev/null || true
                fi
                
                # Electrs datasets
                if zfs list "${ZPOOL}/electrs" >/dev/null 2>&1; then
                    zfs destroy -r "${ZPOOL}/electrs" 2>/dev/null || true
                fi
                
                # Elements datasets
                if zfs list "${ZPOOL}/elements" >/dev/null 2>&1; then
                    zfs destroy -r "${ZPOOL}/elements" 2>/dev/null || true
                fi
                
                # Bitcoin datasets (including testnet, signet, etc.)
                if zfs list "${ZPOOL}/bitcoin" >/dev/null 2>&1; then
                    zfs destroy -r "${ZPOOL}/bitcoin" 2>/dev/null || true
                fi
                
                # Minfee dataset
                if zfs list "${ZPOOL}/minfee" >/dev/null 2>&1; then
                    zfs destroy -r "${ZPOOL}/minfee" 2>/dev/null || true
                fi
                
                # Mempool dataset
                if zfs list "${ZPOOL}/mempool" >/dev/null 2>&1; then
                    zfs destroy -r "${ZPOOL}/mempool" 2>/dev/null || true
                fi
                
                # MySQL dataset
                if zfs list "${ZPOOL}/mysql" >/dev/null 2>&1; then
                    zfs destroy -r "${ZPOOL}/mysql" 2>/dev/null || true
                fi
                
                # Cache dataset
                if zfs list "${ZPOOL}/cache" >/dev/null 2>&1; then
                    zfs destroy -r "${ZPOOL}/cache" 2>/dev/null || true
                fi
                
                # Backup dataset
                if zfs list "${ZPOOL}/backup" >/dev/null 2>&1; then
                    zfs destroy -r "${ZPOOL}/backup" 2>/dev/null || true
                fi
            fi
            
            # Remove directories if they exist (for non-ZFS systems or leftover directories)
            echo "[*] Removing directories..."
            rm -rf "/backup" "${ELEMENTS_HOME}" "${BITCOIN_HOME}" "${MINFEE_HOME}" "${ELECTRS_HOME}" "${MEMPOOL_HOME}" "${MYSQL_HOME}" "${CLN_HOME}" 2>/dev/null || true
            
            # Remove users
            echo "[*] Removing users..."
            pw userdel "${MEMPOOL_USER}" 2>/dev/null || true
            pw userdel "${BITCOIN_USER}" 2>/dev/null || true
            pw userdel "${MINFEE_USER}" 2>/dev/null || true
            pw userdel "${ELEMENTS_USER}" 2>/dev/null || true
            pw userdel "${CLN_USER}" 2>/dev/null || true
            pw userdel "${CKPOOL_USER}" 2>/dev/null || true
            
            # Remove groups
            echo "[*] Removing groups..."
            pw groupdel "${MEMPOOL_GROUP}" 2>/dev/null || true
            pw groupdel "${BITCOIN_GROUP}" 2>/dev/null || true
            pw groupdel "${MINFEE_GROUP}" 2>/dev/null || true
            pw groupdel "${ELEMENTS_GROUP}" 2>/dev/null || true
            pw groupdel "${CLN_GROUP}" 2>/dev/null || true
            pw groupdel "${CKPOOL_GROUP}" 2>/dev/null || true
            
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
            
            # Remove users
            echo "[*] Removing users..."
            userdel "${MEMPOOL_USER}" 2>/dev/null || true
            userdel "${BITCOIN_USER}" 2>/dev/null || true
            userdel "${MINFEE_USER}" 2>/dev/null || true
            userdel "${ELEMENTS_USER}" 2>/dev/null || true
            userdel "${CLN_USER}" 2>/dev/null || true
            userdel "${CKPOOL_USER}" 2>/dev/null || true
            
            # Remove groups
            echo "[*] Removing groups..."
            groupdel "${MEMPOOL_GROUP}" 2>/dev/null || true
            groupdel "${BITCOIN_GROUP}" 2>/dev/null || true
            groupdel "${MINFEE_GROUP}" 2>/dev/null || true
            groupdel "${ELEMENTS_GROUP}" 2>/dev/null || true
            groupdel "${CLN_GROUP}" 2>/dev/null || true
            groupdel "${CKPOOL_GROUP}" 2>/dev/null || true
            
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

# Make the function available to the main script in zsh
typeset -fx clean_install
