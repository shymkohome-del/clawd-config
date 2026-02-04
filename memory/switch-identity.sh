#!/bin/bash
# =============================================================================
# Identity Switcher for Crypto Market
# Ensures correct identity is used for each environment
# =============================================================================
# Usage: ./switch-identity.sh [local|staging|production]
# Returns: 0 if identity switched successfully, 1 if failed
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $*"; }
log_error() { echo -e "${RED}✗${NC} $*"; }
log_critical() { echo -e "${RED}🚨 CRITICAL: $*${NC}"; }
log_cyan() { echo -e "${CYAN}$*${NC}"; }

# =============================================================================
# CONFIGURATION FROM SAFETY VAULT
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

# Critical identity from Safety Vault
PRODUCTION_IDENTITY="ic_user"
PRODUCTION_PRINCIPAL="4gcgh-7p3b4-gznop-3q5kh-sx3zl-fz2qd-6cmhh-gxdd6-g6agu-zptr7-kqe"
LOCAL_IDENTITY="default"
LOCAL_PRINCIPAL="bibc2-doxoe-vtsrh-skwdg-yzeth-le466-hgo3f-ykxin-6woib-pwask-zae"

# Production canister IDs
PROD_ATOMIC_SWAP="6p4bg-hiaaa-aaaad-ad6ea-cai"
PROD_MARKETPLACE="6b6mo-4yaaa-aaaad-ad6fa-cai"
PROD_USER_MANAGEMENT="6i5hs-kqaaa-aaaad-ad6eq-cai"
PROD_PRICE_ORACLE="6g7k2-raaaa-aaaad-ad6fq-cai"
PROD_MESSAGING="6ty3x-qiaaa-aaaad-ad6ga-cai"
PROD_DISPUTE="6uz5d-5qaaa-aaaad-ad6gq-cai"
PROD_PERFORMANCE="652w7-lyaaa-aaaad-ad6ha-cai"

# =============================================================================
# FUNCTIONS
# =============================================================================

show_vault_banner() {
    echo ""
    log_cyan "╔════════════════════════════════════════════════════════════════════╗"
    log_cyan "║          🔐 CRYPTO MARKET IDENTITY SWITCHER                        ║"
    log_cyan "║          Safety Vault Integration                                  ║"
    log_cyan "╚════════════════════════════════════════════════════════════════════╝"
    echo ""
}

verify_dfx_available() {
    if ! command -v dfx &>/dev/null; then
        log_error "dfx not found in PATH"
        log_info "Install dfx: https://internetcomputer.org/docs/current/developer-docs/setup/install"
        return 1
    fi
    return 0
}

verify_identity_exists() {
    local identity="$1"
    local identity_dir="$HOME/.config/dfx/identity/$identity"
    
    if [[ ! -d "$identity_dir" ]]; then
        log_error "Identity '$identity' not found at: $identity_dir"
        log_info "Available identities:"
        ls -1 "$HOME/.config/dfx/identity/" 2>/dev/null || echo "  (none found)"
        return 1
    fi
    
    if [[ ! -f "$identity_dir/identity.pem" ]]; then
        log_error "Private key missing for identity '$identity'"
        return 1
    fi
    
    log_success "Identity '$identity' exists and has private key"
    return 0
}

switch_identity() {
    local identity="$1"
    
    log_info "Switching to identity: $identity"
    
    if ! dfx identity use "$identity" 2>/dev/null; then
        log_error "Failed to switch to identity '$identity'"
        return 1
    fi
    
    log_success "Switched to identity: $identity"
    return 0
}

verify_principal() {
    local expected_principal="$1"
    local identity="$2"
    
    log_info "Verifying principal for identity: $identity"
    
    local actual_principal
    actual_principal=$(dfx identity get-principal 2>/dev/null)
    
    if [[ -z "$actual_principal" ]]; then
        log_error "Could not get principal for identity '$identity'"
        return 1
    fi
    
    log_info "Expected: $expected_principal"
    log_info "Actual:   $actual_principal"
    
    if [[ "$actual_principal" == "$expected_principal" ]]; then
        log_success "Principal verified and matches Safety Vault"
        return 0
    else
        log_critical "PRINCIPAL MISMATCH!"
        log_critical "This identity may have been compromised or regenerated"
        return 1
    fi
}

show_identity_info() {
    local identity="$1"
    local environment="$2"
    
    echo ""
    log_cyan "╔════════════════════════════════════════════════════════════════════╗"
    log_cyan "║          IDENTITY SWITCHED SUCCESSFULLY                            ║"
    log_cyan "╚════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    log_success "Current Identity: $identity"
    log_success "Environment: $environment"
    log_success "Principal: $(dfx identity get-principal 2>/dev/null)"
    
    if [[ "$environment" == "production" ]]; then
        echo ""
        log_critical "⚠️  YOU ARE NOW USING PRODUCTION IDENTITY"
        log_critical "⚠️  ALL OPERATIONS WILL AFFECT MAINNET CANISTERS"
        echo ""
        log_info "Controlled Production Canisters:"
        echo "  • atomic_swap:      $PROD_ATOMIC_SWAP"
        echo "  • marketplace:      $PROD_MARKETPLACE"
        echo "  • user_management:  $PROD_USER_MANAGEMENT"
        echo "  • price_oracle:     $PROD_PRICE_ORACLE"
        echo "  • messaging:        $PROD_MESSAGING"
        echo "  • dispute:          $PROD_DISPUTE"
        echo "  • performance:      $PROD_PERFORMANCE"
        echo ""
        log_critical "BE EXTREMELY CAREFUL WITH ALL COMMANDS"
    fi
    
    echo ""
}

handle_local() {
    log_info "Setting up for LOCAL development"
    
    verify_identity_exists "$LOCAL_IDENTITY" || return 1
    switch_identity "$LOCAL_IDENTITY" || return 1
    verify_principal "$LOCAL_PRINCIPAL" "$LOCAL_IDENTITY" || return 1
    
    show_identity_info "$LOCAL_IDENTITY" "local"
    
    log_success "Ready for local development"
    log_info "You can now run: /run local"
    
    return 0
}

handle_staging() {
    log_info "Setting up for STAGING environment"
    
    verify_identity_exists "$PRODUCTION_IDENTITY" || return 1
    switch_identity "$PRODUCTION_IDENTITY" || return 1
    verify_principal "$PRODUCTION_PRINCIPAL" "$PRODUCTION_IDENTITY" || return 1
    
    show_identity_info "$PRODUCTION_IDENTITY" "staging"
    
    log_warning "⚠️  Staging uses mainnet (ic) network"
    log_warning "⚠️  Operations will cost real ICP"
    echo ""
    log_info "You can now run: /run staging"
    
    return 0
}

handle_production() {
    log_info "Setting up for PRODUCTION environment"
    
    verify_identity_exists "$PRODUCTION_IDENTITY" || return 1
    switch_identity "$PRODUCTION_IDENTITY" || return 1
    verify_principal "$PRODUCTION_PRINCIPAL" "$PRODUCTION_IDENTITY" || return 1
    
    show_identity_info "$PRODUCTION_IDENTITY" "production"
    
    log_critical "════════════════════════════════════════════════════════════"
    log_critical "  MAINNET IDENTITY ACTIVE"
    log_critical "  YOU ARE ABOUT TO PERFORM OPERATIONS ON PRODUCTION"
    log_critical "════════════════════════════════════════════════════════════"
    echo ""
    
    read -p "Type 'PROCEED' to confirm you understand the risks: " confirm
    
    if [[ "$confirm" != "PROCEED" ]]; then
        log_error "Confirmation failed - switching back to safe identity"
        dfx identity use "$LOCAL_IDENTITY" 2>/dev/null || true
        return 1
    fi
    
    log_success "Identity confirmed for production operations"
    log_info "You can now run: /run production"
    
    return 0
}

show_help() {
    echo ""
    log_cyan "Crypto Market Identity Switcher"
    echo ""
    log_info "Usage: $0 [local|staging|production]"
    echo ""
    log_info "Environments:"
    echo "  local       - Use 'default' identity for local development"
    echo "  staging     - Use 'ic_user' identity for staging (mainnet)"
    echo "  production  - Use 'ic_user' identity for production (mainnet) ⚠️"
    echo ""
    log_info "This script ensures:"
    echo "  ✓ Correct identity is selected"
    echo "  ✓ Principal matches Safety Vault registry"
    echo "  ✓ User confirmation for dangerous operations"
    echo ""
    log_info "Safety Vault: memory/CRYPTO_MARKET_SAFETY_VAULT.md"
    echo ""
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    show_vault_banner
    
    # Check if dfx is available
    verify_dfx_available || exit 1
    
    # Parse argument
    ENVIRONMENT="${1:-}"
    
    if [[ -z "$ENVIRONMENT" ]]; then
        show_help
        exit 1
    fi
    
    case "$ENVIRONMENT" in
        local|dev|development)
            handle_local
            ;;
        staging|stage|stg)
            handle_staging
            ;;
        production|prod|ic|mainnet)
            handle_production
            ;;
        help|--help|-h)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown environment: $ENVIRONMENT"
            show_help
            exit 1
            ;;
    esac
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
