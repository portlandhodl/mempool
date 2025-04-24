#!/usr/bin/env zsh

# remove_users_groups: Removes all mempool-related users and groups
# This can be used both during clean installation and regular installation
remove_users_groups() {
    # Function to remove cronjobs for a user
    remove_user_cronjobs() {
        local user=$1
        local os=$2
        
        if [ -z "$user" ]; then
            return
        fi
        
        echo "[*] Removing cronjobs for user: ${user}"
        case $os in
            FreeBSD|Debian)
                if id "${user}" >/dev/null 2>&1; then
                    # Use yes command to automatically answer "y" to any prompts
                    # or the -f flag if supported by the system's crontab
                    if yes | crontab -r -u "${user}" 2>/dev/null; then
                        echo "[*] Successfully removed cronjobs for user: ${user}"
                    else
                        echo "[*] No cronjobs found or failed to remove for user: ${user}"
                    fi
                fi
                ;;
        esac
    }
    
    # Function to kill all processes owned by a user
    # Note: Process killing is disabled to prevent script hanging
    kill_user_processes() {
        local user=$1
        local os=$2
        
        # Simply log that we would kill processes, but don't actually do it
        echo "[*] Skipping process killing for user: ${user} (disabled to prevent hanging)"
    }
    
    case $OS in
        FreeBSD)
            # Kill processes and remove service users
            echo "[*] Removing users..."
            for user in "${MEMPOOL_USER}" "${BITCOIN_USER}" "${MINFEE_USER}" "${ELEMENTS_USER}" "${CLN_USER}" "${CKPOOL_USER}"; do
                if id "${user}" >/dev/null 2>&1; then
                    echo "[*] Processing user: ${user}"
                    remove_user_cronjobs "${user}" "${OS}"
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
                            remove_user_cronjobs "${user}" "${OS}"
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
                    remove_user_cronjobs "${user}" "${OS}"
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
                            remove_user_cronjobs "${user}" "${OS}"
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
