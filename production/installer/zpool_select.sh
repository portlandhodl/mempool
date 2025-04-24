#!/usr/bin/env zsh

# select_zpool: Handles ZFS pool detection and selection
# Returns the selected pool name or empty string if no pool selected
select_zpool() {
    local ZPOOL=""
    
    # Only check for ZFS pools on FreeBSD systems
    if [ "${OS}" = FreeBSD ]; then
        # Verify zpool command is available
        if command -v zpool &> /dev/null; then
            # Get list of available zpools
            local AVAILABLE_ZPOOLS=$(zpool list -H -o name 2>/dev/null)
            
            if [ -z "$AVAILABLE_ZPOOLS" ]; then
                echo "[!] No ZFS pools found on this system. ZFS features will not be available."
                ZPOOL=""
            else
                # Count available pools
                local POOL_COUNT=$(echo "$AVAILABLE_ZPOOLS" | wc -l)
                
                # Auto-select if only one pool exists
                if [ "$POOL_COUNT" -eq 1 ]; then
                    ZPOOL="$AVAILABLE_ZPOOLS"
                    echo "[*] Automatically selected the only available ZFS pool: $ZPOOL"
                else
                    echo "[*] Available ZFS pools:"
                    # Build array of pool names
                    local ZPOOL_ARRAY=()
                    local i=1
                    while IFS= read -r pool; do
                        echo "  $i) $pool"
                        ZPOOL_ARRAY+=("$pool")
                        ((i++))
                    done <<< "$AVAILABLE_ZPOOLS"
                    
                    # Add non-ZFS option
                    echo "  $i) Don't use ZFS"
                    
                    # Get user selection
                    echo -n "Select a ZFS pool to use (1-$i): "
                    read POOL_SELECTION
                    
                    if [[ "$POOL_SELECTION" =~ ^[0-9]+$ ]] && [ "$POOL_SELECTION" -ge 1 ] && [ "$POOL_SELECTION" -le "$i" ]; then
                        if [ "$POOL_SELECTION" -eq "$i" ]; then
                            echo "[*] ZFS will not be used for this installation."
                            ZPOOL=""
                        else
                            ZPOOL="${ZPOOL_ARRAY[$((POOL_SELECTION-1))]}"
                            echo "[*] Using ZFS pool: $ZPOOL"
                        fi
                    else
                        echo "[!] Invalid selection. ZFS will not be used."
                        ZPOOL=""
                    fi
                fi
            fi
        else
            echo "[!] ZFS is not installed on this system. ZFS features will not be available."
            ZPOOL=""
        fi
    fi
    
    # Return selected pool name
    echo "$ZPOOL"
}

# Make the function available to the main script
if [ -n "$BASH_VERSION" ]; then
    export -f select_zpool
else
    typeset -f select_zpool
fi
