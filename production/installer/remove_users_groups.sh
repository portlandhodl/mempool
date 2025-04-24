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
            pw groupdel -f "${MEMPOOL_GROUP}" 2>/dev/null || true
            pw groupdel -f "${BITCOIN_GROUP}" 2>/dev/null || true
            pw groupdel -f "${MINFEE_GROUP}" 2>/dev/null || true
            pw groupdel -f "${ELEMENTS_GROUP}" 2>/dev/null || true
            pw groupdel -f "${CLN_GROUP}" 2>/dev/null || true
            pw groupdel -f "${CKPOOL_GROUP}" 2>/dev/null || true
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
            groupdel -f "${MEMPOOL_GROUP}" 2>/dev/null || true
            groupdel -f "${BITCOIN_GROUP}" 2>/dev/null || true
            groupdel -f "${MINFEE_GROUP}" 2>/dev/null || true
            groupdel -f "${ELEMENTS_GROUP}" 2>/dev/null || true
            groupdel -f "${CLN_GROUP}" 2>/dev/null || true
            groupdel -f "${CKPOOL_GROUP}" 2>/dev/null || true
        ;;
    esac
}

# Export function for shell compatibility
if [ -n "$BASH_VERSION" ]; then
    export -f remove_users_groups
else
    typeset -f remove_users_groups
fi
