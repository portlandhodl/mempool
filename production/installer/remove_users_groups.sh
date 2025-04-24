#!/usr/bin/env zsh

# remove_users_groups: Removes all mempool-related users and groups
# This can be used both during clean installation and regular installation
remove_users_groups() {
    # Function to kill all processes owned by a user
    kill_user_processes() {
        local user=$1
        local os=$2
        
        if [ -z "$user" ]; then
            return
        fi
        
        echo "[*] Killing all processes owned by user: ${user}"
        case $os in
            FreeBSD)
                # Get all PIDs for the user and kill them
                pids=$(ps -U "${user}" -o pid= 2>/dev/null)
                if [ ! -z "$pids" ]; then
                    echo "[*] Found processes: $pids"
                    for pid in $pids; do
                        echo "[*] Killing process $pid owned by ${user}"
                        kill -9 $pid 2>/dev/null || true
                    done
                else
                    echo "[*] No processes found for user ${user}"
                fi
                ;;
            Debian)
                # Get all PIDs for the user and kill them
                pids=$(ps -u "${user}" -o pid= 2>/dev/null)
                if [ ! -z "$pids" ]; then
                    echo "[*] Found processes: $pids"
                    for pid in $pids; do
                        echo "[*] Killing process $pid owned by ${user}"
                        kill -9 $pid 2>/dev/null || true
                    done
                else
                    echo "[*] No processes found for user ${user}"
                fi
                ;;
        esac
        
        # Give processes time to terminate
        sleep 1
    }
    
    case $OS in
        FreeBSD)
            # Kill processes and remove service users
            echo "[*] Removing users..."
            for user in "${MEMPOOL_USER}" "${BITCOIN_USER}" "${MINFEE_USER}" "${ELEMENTS_USER}" "${CLN_USER}" "${CKPOOL_USER}"; do
                if id "${user}" >/dev/null 2>&1; then
                    echo "[*] Processing user: ${user}"
                    kill_user_processes "${user}" "${OS}"
                    
                    echo "[*] Deleting user: ${user}"
                    if pw userdel -f "${user}" 2>/dev/null; then
                        echo "[*] Successfully deleted user: ${user}"
                    else
                        echo "[!] Failed to delete user: ${user}, retrying..."
                        # Try one more time after a short delay
                        sleep 2
                        if pw userdel -f "${user}" 2>/dev/null; then
                            echo "[*] Successfully deleted user on second attempt: ${user}"
                        else
                            echo "[!] Failed to delete user after retry: ${user}"
                        fi
                    fi
                else
                    echo "[*] User does not exist: ${user}"
                fi
            done
            
            # Remove service groups
            echo "[*] Removing groups..."
            # Force remove groups even if they have users
            for group in "${MEMPOOL_GROUP}" "${BITCOIN_GROUP}" "${MINFEE_GROUP}" "${ELEMENTS_GROUP}" "${CLN_GROUP}" "${CKPOOL_GROUP}"; do
                if pw group show "${group}" >/dev/null 2>&1; then
                    echo "[*] Processing group: ${group}"
                    users=$(pw group show "${group}" | cut -d: -f4)
                    if [ ! -z "${users}" ]; then
                        echo "[*] Removing users from group ${group}: ${users}"
                        for user in $(echo "${users}" | tr ',' ' '); do
                            echo "[*] Removing user ${user} from group ${group}"
                            kill_user_processes "${user}" "${OS}"
                            if pw userdel -f "${user}" 2>/dev/null; then
                                echo "[*] Successfully deleted user: ${user}"
                            else
                                echo "[!] Failed to delete user: ${user}"
                            fi
                        done
                    fi
                    
                    echo "[*] Deleting group: ${group}"
                    if pw groupdel -f "${group}" 2>/dev/null; then
                        echo "[*] Successfully deleted group: ${group}"
                    else
                        echo "[!] Failed to delete group: ${group}, retrying..."
                        # Try one more time after a short delay
                        sleep 2
                        if pw groupdel -f "${group}" 2>/dev/null; then
                            echo "[*] Successfully deleted group on second attempt: ${group}"
                        else
                            echo "[!] Failed to delete group after retry: ${group}"
                        fi
                    fi
                else
                    echo "[*] Group does not exist: ${group}"
                fi
            done
        ;;
        
        Debian)
            # Kill processes and remove service users
            echo "[*] Removing users..."
            for user in "${MEMPOOL_USER}" "${BITCOIN_USER}" "${MINFEE_USER}" "${ELEMENTS_USER}" "${CLN_USER}" "${CKPOOL_USER}"; do
                if id "${user}" >/dev/null 2>&1; then
                    echo "[*] Processing user: ${user}"
                    kill_user_processes "${user}" "${OS}"
                    
                    echo "[*] Deleting user: ${user}"
                    if userdel -f "${user}" 2>/dev/null; then
                        echo "[*] Successfully deleted user: ${user}"
                    else
                        echo "[!] Failed to delete user: ${user}, retrying..."
                        # Try one more time after a short delay
                        sleep 2
                        if userdel -f "${user}" 2>/dev/null; then
                            echo "[*] Successfully deleted user on second attempt: ${user}"
                        else
                            echo "[!] Failed to delete user after retry: ${user}"
                        fi
                    fi
                else
                    echo "[*] User does not exist: ${user}"
                fi
            done
            
            # Remove service groups
            echo "[*] Removing groups..."
            for group in "${MEMPOOL_GROUP}" "${BITCOIN_GROUP}" "${MINFEE_GROUP}" "${ELEMENTS_GROUP}" "${CLN_GROUP}" "${CKPOOL_GROUP}"; do
                if getent group "${group}" >/dev/null 2>&1; then
                    echo "[*] Processing group: ${group}"
                    users=$(getent group "${group}" | cut -d: -f4)
                    if [ ! -z "${users}" ]; then
                        echo "[*] Removing users from group ${group}: ${users}"
                        for user in $(echo "${users}" | tr ',' ' '); do
                            echo "[*] Removing user ${user} from group ${group}"
                            kill_user_processes "${user}" "${OS}"
                            if userdel -f "${user}" 2>/dev/null; then
                                echo "[*] Successfully deleted user: ${user}"
                            else
                                echo "[!] Failed to delete user: ${user}"
                            fi
                        done
                    fi
                    
                    echo "[*] Deleting group: ${group}"
                    if groupdel -f "${group}" 2>/dev/null; then
                        echo "[*] Successfully deleted group: ${group}"
                    else
                        echo "[!] Failed to delete group: ${group}, retrying..."
                        # Try one more time after a short delay
                        sleep 2
                        if groupdel -f "${group}" 2>/dev/null; then
                            echo "[*] Successfully deleted group on second attempt: ${group}"
                        else
                            echo "[!] Failed to delete group after retry: ${group}"
                        fi
                    fi
                else
                    echo "[*] Group does not exist: ${group}"
                fi
            done
        ;;
    esac
}

# Export function for shell compatibility
if [ -n "$BASH_VERSION" ]; then
    export -f remove_users_groups
fi
