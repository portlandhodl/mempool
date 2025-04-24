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
                    # First, ensure the user is not logged in
                    echo "[*] Checking if user ${user} is logged in"
                    pkill -KILL -u "${user}" 2>/dev/null || true
                    
                    # Try with more forceful options for FreeBSD
                    echo "[*] Attempting to delete user with pw userdel -r -f"
                    if pw userdel -r -f "${user}" 2>/dev/null; then
                        echo "[*] Successfully deleted user: ${user}"
                    else
                        echo "[!] Failed to delete user: ${user}, retrying with additional options..."
                        # Try one more time with even more forceful approach
                        sleep 2
                        
                        # First try to remove the user from all groups
                        echo "[*] Attempting to remove user from all groups"
                        groups=$(pw user show "${user}" | cut -d: -f4 2>/dev/null || echo "")
                        if [ ! -z "${groups}" ]; then
                            for group in $(echo "${groups}" | tr ',' ' '); do
                                echo "[*] Removing user ${user} from group ${group}"
                                pw groupmod "${group}" -d "${user}" 2>/dev/null || true
                            done
                        fi
                        
                        # Check for any remaining processes and kill them
                        echo "[*] Checking for any remaining processes for user ${user}"
                        pids=$(ps -U "${user}" -o pid= 2>/dev/null || echo "")
                        if [ ! -z "${pids}" ]; then
                            echo "[*] Found processes: ${pids}, killing them"
                            for pid in ${pids}; do
                                kill -9 "${pid}" 2>/dev/null || true
                            done
                            sleep 1
                        fi
                        
                        # Now try to delete the user again
                        echo "[*] Attempting to delete user with pw userdel -r -f (second attempt)"
                        if pw userdel -r -f "${user}" 2>/dev/null; then
                            echo "[*] Successfully deleted user on second attempt: ${user}"
                        else
                            echo "[!] Failed to delete user after retry: ${user}"
                            
                            # Try to remove any locks that might be preventing deletion
                            echo "[*] Checking for lock files"
                            rm -f /var/run/pw/* 2>/dev/null || true
                            
                            # As a last resort, try with rmuser which is more interactive but can be more thorough
                            echo "[*] Attempting with rmuser as last resort"
                            yes | rmuser -y "${user}" 2>/dev/null
                            
                            # If that still fails, try direct manipulation of passwd and master.passwd
                            if id "${user}" >/dev/null 2>&1; then
                                echo "[*] All standard methods failed, attempting direct file manipulation"
                                # Backup files first
                                cp /etc/passwd /etc/passwd.bak 2>/dev/null || true
                                cp /etc/master.passwd /etc/master.passwd.bak 2>/dev/null || true
                                
                                # Remove user from passwd files
                                grep -v "^${user}:" /etc/passwd > /tmp/passwd.new 2>/dev/null && mv /tmp/passwd.new /etc/passwd 2>/dev/null || true
                                grep -v "^${user}:" /etc/master.passwd > /tmp/master.passwd.new 2>/dev/null && mv /tmp/master.passwd.new /etc/master.passwd 2>/dev/null || true
                                
                                # Rebuild password database
                                pwd_mkdb -p /etc/master.passwd 2>/dev/null || true
                                
                                echo "[*] Attempted direct removal from password files"
                            fi
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
                    # First ensure all users are removed from the group
                    users=$(pw group show "${group}" | cut -d: -f4 2>/dev/null || echo "")
                    if [ ! -z "${users}" ]; then
                        echo "[*] Removing all users from group ${group} before deletion"
                        for user in $(echo "${users}" | tr ',' ' '); do
                            echo "[*] Removing user ${user} from group ${group}"
                            pw groupmod "${group}" -d "${user}" 2>/dev/null || true
                        done
                    fi
                    
                    # Now try to delete the group
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
                            # As a last resort, try with more forceful approach
                            echo "[*] Attempting with more forceful approach"
                            # Try to remove the group from /etc/group directly as a last resort
                            if grep -q "^${group}:" /etc/group; then
                                echo "[*] Removing group ${group} entry from /etc/group"
                                sed -i.bak "/^${group}:/d" /etc/group 2>/dev/null || true
                                echo "[*] Attempted direct removal of group from /etc/group"
                            fi
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
