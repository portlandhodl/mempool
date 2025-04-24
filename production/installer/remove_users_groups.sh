#!/usr/bin/env zsh

# remove_users_groups: Removes all mempool-related users and groups
# This can be used both during clean installation and regular installation
remove_users_groups() {
    case $OS in
        FreeBSD)
            # Remove service users
            echo "[*] Removing users..."
            pw userdel -f "${MEMPOOL_USER}" 2>/dev/null || true
            pw userdel -f "${BITCOIN_USER}" 2>/dev/null || true
            pw userdel -f "${MINFEE_USER}" 2>/dev/null || true
            pw userdel -f "${ELEMENTS_USER}" 2>/dev/null || true
            pw userdel -f "${CLN_USER}" 2>/dev/null || true
            pw userdel -f "${CKPOOL_USER}" 2>/dev/null || true
            
            # Remove service groups
            echo "[*] Removing groups..."
            # Force remove groups even if they have users
            for group in "${MEMPOOL_GROUP}" "${BITCOIN_GROUP}" "${MINFEE_GROUP}" "${ELEMENTS_GROUP}" "${CLN_GROUP}" "${CKPOOL_GROUP}"; do
                if pw group show "${group}" >/dev/null 2>&1; then
                    users=$(pw group show "${group}" | cut -d: -f4)
                    if [ ! -z "${users}" ]; then
                        echo "[*] Removing users from group ${group}: ${users}"
                        for user in $(echo "${users}" | tr ',' ' '); do
                            pw userdel -f "${user}" 2>/dev/null || true
                        done
                    fi
                fi
                echo "[*] Removing group ${group}"
                pw groupdel -f "${group}" 2>/dev/null || true
            done
        ;;
        
        Debian)
            # Remove service users
            echo "[*] Removing users..."
            userdel -f "${MEMPOOL_USER}" 2>/dev/null || true
            userdel -f "${BITCOIN_USER}" 2>/dev/null || true
            userdel -f "${MINFEE_USER}" 2>/dev/null || true
            userdel -f "${ELEMENTS_USER}" 2>/dev/null || true
            userdel -f "${CLN_USER}" 2>/dev/null || true
            userdel -f "${CKPOOL_USER}" 2>/dev/null || true
            
            # Remove service groups
            echo "[*] Removing groups..."
            for group in "${MEMPOOL_GROUP}" "${BITCOIN_GROUP}" "${MINFEE_GROUP}" "${ELEMENTS_GROUP}" "${CLN_GROUP}" "${CKPOOL_GROUP}"; do
                if getent group "${group}" >/dev/null 2>&1; then
                    users=$(getent group "${group}" | cut -d: -f4)
                    if [ ! -z "${users}" ]; then
                        echo "[*] Removing users from group ${group}: ${users}"
                        for user in $(echo "${users}" | tr ',' ' '); do
                            userdel -f "${user}" 2>/dev/null || true
                        done
                    fi
                fi
                echo "[*] Removing group ${group}"
                groupdel -f "${group}" 2>/dev/null || true
            done
        ;;
    esac
}

# Export function for shell compatibility
if [ -n "$BASH_VERSION" ]; then
    export -f remove_users_groups
else
    typeset -f remove_users_groups
fi
