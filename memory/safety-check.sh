#!/bin/bash
# =============================================================================
# Pre-Flight Safety Check Script
# Critical safety validation before ANY ICP operation
# =============================================================================
# Usage: ./safety-check.sh [environment]
# Returns: 0 if safe to proceed, 1 if unsafe
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $*"; }
log_error() { echo -e "${RED}✗${NC} $*"; }
log_critical() { echo -e "${RED}🚨 CRITICAL: $*${NC}"; }

# =============================================================================
# CONFIGURATION
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
MANIFEST_FILE="$PROJECT_ROOT/memory/ENVIRONMENT_SAFETY_MANIFEST.md"
CANISTER_IDS_FILE="$PROJECT_ROOT/crypto_market/canister_ids.json"
CHECKPOINT_FILE="$PROJECT_ROOT/_bmad/_memory/run-checkpoint.yaml"

# Production Canister IDs (from manifest - NEVER CHANGE THESE)
declare -A PROD_CANISTER_IDS=(
    ["atomic_swap"]="6p4bg-hiaaa-aaaad-ad6ea-cai"
    ["marketplace"]="6b6mo-4yaaa-aaaad-ad6fa-cai"
    ["user_management"]="6i5hs-kqaaa-aaaad-ad6eq-cai"
    ["price_oracle"]="6g7k2-raaaa-aaaad-ad6fq-cai"
    ["messaging"]="6ty3x-qiaaa-aaaad-ad6ga-cai"
    ["dispute"]="6uz5d-5qaaa-aaaad-ad6gq-cai"
    ["performance_monitor"]="652w7-lyaaa-aaaad-ad6ha-cai"
)

# =============================================================================
# SAFETY CHECKS
# =============================================================================

check_environment_argument() {
    log_info "Checking environment argument..."
    
    ENVIRONMENT="${1:-}"
    
    if [[ -z "$ENVIRONMENT" ]]; then
        log_error "No environment specified"
        log_info "Usage: $0 [local|staging|production]"
        return 1
    fi
    
    case "$ENVIRONMENT" in
        local|dev|development)
            ENVIRONMENT="local"
            NETWORK="local"
            DANGER_LEVEL="SAFE"
            ;;
        staging|stage|stg)
            ENVIRONMENT="staging"
            NETWORK="ic"
            DANGER_LEVEL="WARNING"
            ;;
        production|prod|ic|mainnet)
            ENVIRONMENT="production"
            NETWORK="ic"
            DANGER_LEVEL="DANGER"
            ;;
        *)
            log_error "Unknown environment: $ENVIRONMENT"
            log_info "Valid options: local, staging, production"
            return 1
            ;;
    esac
    
    log_success "Environment: $ENVIRONMENT"
    log_success "Network: $NETWORK"
    
    if [[ "$DANGER_LEVEL" == "DANGER" ]]; then
        log_critical "MAINNET OPERATION DETECTED"
        log_critical "This will use REAL ICP and affect PRODUCTION canisters"
    elif [[ "$DANGER_LEVEL" == "WARNING" ]]; then
        log_warning "STAGING/MAINNET operation - will use real blockchain"
    else
        log_success "Safe zone - local development"
    fi
    
    return 0
}

check_canister_ids_file() {
    log_info "Checking canister_ids.json..."
    
    if [[ ! -f "$CANISTER_IDS_FILE" ]]; then
        log_error "canister_ids.json not found: $CANISTER_IDS_FILE"
        return 1
    fi
    
    # Check if file is valid JSON
    if ! jq empty "$CANISTER_IDS_FILE" 2>/dev/null; then
        log_error "canister_ids.json is not valid JSON!"
        return 1
    fi
    
    # Check if production IDs are present and correct
    local all_correct=true
    for canister in "${!PROD_CANISTER_IDS[@]}"; do
        local expected_id="${PROD_CANISTER_IDS[$canister]}"
        local actual_id=$(jq -r ".${canister}.ic // empty" "$CANISTER_IDS_FILE" 2>/dev/null || echo "")
        
        if [[ -z "$actual_id" ]]; then
            log_warning "Production ID for $canister not found in canister_ids.json"
            all_correct=false
        elif [[ "$actual_id" != "$expected_id" ]]; then
            log_critical "PRODUCTION ID MISMATCH for $canister!"
            log_critical "  Expected: $expected_id"
            log_critical "  Actual:   $actual_id"
            all_correct=false
        fi
    done
    
    if [[ "$all_correct" == "true" ]]; then
        log_success "All production canister IDs verified and correct"
    else
        log_warning "Some canister ID issues detected"
    fi
    
    return 0
}

check_backup_exists() {
    log_info "Checking for backups..."
    
    local backup_dir="$PROJECT_ROOT/crypto_market/.dfx/backups"
    local manifest_backup="$PROJECT_ROOT/memory/canister_ids.json.backup"
    
    local backup_count=0
    
    if [[ -d "$backup_dir" ]]; then
        backup_count=$(find "$backup_dir" -name "canister_ids.json.backup.*" | wc -l)
    fi
    
    if [[ -f "$manifest_backup" ]]; then
        ((backup_count++))
    fi
    
    if [[ $backup_count -gt 0 ]]; then
        log_success "Found $backup_count backup(s)"
    else
        log_warning "No backups found - creating emergency backup now"
        create_emergency_backup
    fi
    
    return 0
}

create_emergency_backup() {
    local backup_file="$PROJECT_ROOT/memory/canister_ids.json.backup.$(date +%s)"
    cp "$CANISTER_IDS_FILE" "$backup_file"
    log_success "Emergency backup created: $backup_file"
}

check_env_files() {
    log_info "Checking .env files..."
    
    local env_dev="$PROJECT_ROOT/.env"
    local env_stg="$PROJECT_ROOT/crypto_market/.env.stg"
    local env_prod="$PROJECT_ROOT/crypto_market/.env.prod"
    
    # Check if correct .env exists for environment
    case "$ENVIRONMENT" in
        local)
            if [[ -f "$env_dev" ]]; then
                log_success ".env (dev) exists"
                verify_env_canister_ids "$env_dev" "local"
            else
                log_warning ".env not found - will be created"
            fi
            ;;
        staging)
            if [[ -f "$env_stg" ]]; then
                log_success ".env.stg exists"
                verify_env_canister_ids "$env_stg" "ic"
            else
                log_warning ".env.stg not found"
            fi
            ;;
        production)
            if [[ -f "$env_prod" ]]; then
                log_success ".env.prod exists"
                verify_env_canister_ids "$env_prod" "ic"
            else
                log_warning ".env.prod not found"
            fi
            ;;
    esac
    
    return 0
}

verify_env_canister_ids() {
    local env_file="$1"
    local expected_network="$2"
    
    log_info "Verifying canister IDs in $env_file..."
    
    # Check for common canister ID variables
    local marketplace_id=$(grep "^CANISTER_ID_MARKETPLACE=" "$env_file" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "")
    
    if [[ -z "$marketplace_id" ]]; then
        log_warning "CANISTER_ID_MARKETPLACE not found in $env_file"
        return 1
    fi
    
    # Check if ID matches expected network
    if [[ "$expected_network" == "ic" ]]; then
        # Production IDs should NOT start with 'u' (local IDs do)
        if [[ "$marketplace_id" == u* ]]; then
            log_critical "ENV FILE CONTAINS LOCAL CANISTER ID!"
            log_critical "  File: $env_file"
            log_critical "  ID: $marketplace_id (looks like local ID)"
            log_critical "  Expected: Production ID (ic network)"
            return 1
        fi
    else
        # Local IDs should start with 'u'
        if [[ ! "$marketplace_id" == u* ]]; then
            log_warning "Local .env contains non-local looking ID: $marketplace_id"
            log_warning "This may be intentional if using persistent local canisters"
        fi
    fi
    
    log_success "Canister ID in .env looks correct for $expected_network"
    return 0
}

check_wallet_balance() {
    if [[ "$NETWORK" != "ic" ]]; then
        return 0  # Skip for local
    fi
    
    log_info "Checking wallet balance (mainnet)..."
    
    # Try to get wallet balance
    local balance_output
    if balance_output=$(dfx wallet balance --network ic 2>&1); then
        log_success "Wallet balance: $balance_output"
        
        # Parse balance (assume format like "12.345 TC")
        if echo "$balance_output" | grep -q "TC"; then
            local tc_value=$(echo "$balance_output" | grep -oE '[0-9]+(\.[0-9]+)?' | head -1)
            if (( $(echo "$tc_value < 0.5" | bc -l) )); then
                log_warning "Low wallet balance: $balance_output"
                log_warning "Consider topping up before deployment"
            fi
        fi
    else
        log_warning "Could not check wallet balance"
        log_warning "Error: $balance_output"
    fi
    
    return 0
}

check_dfx_configuration() {
    log_info "Checking DFX configuration..."
    
    local dfx_json="$PROJECT_ROOT/crypto_market/dfx.json"
    
    if [[ ! -f "$dfx_json" ]]; then
        log_error "dfx.json not found"
        return 1
    fi
    
    # Verify network configuration
    local networks=$(jq -r '.networks | keys[]' "$dfx_json" 2>/dev/null || echo "")
    
    if [[ -z "$networks" ]]; then
        log_error "No networks configured in dfx.json"
        return 1
    fi
    
    log_success "DFX networks configured: $networks"
    
    # Check if requested network exists
    if ! echo "$networks" | grep -q "^${NETWORK}$"; then
        log_error "Network '$NETWORK' not found in dfx.json"
        log_info "Available networks: $networks"
        return 1
    fi
    
    return 0
}

# =============================================================================
# MAIN SAFETY CHECK
# =============================================================================

run_safety_checks() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║          🛡️  PRE-FLIGHT SAFETY CHECK                              ║"
    echo "║          Crypto Market - Environment Safety Validation             ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    local exit_code=0
    
    # Run all checks
    check_environment_argument "$1" || exit_code=1
    
    if [[ $exit_code -eq 0 ]]; then
        check_canister_ids_file || exit_code=1
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        check_backup_exists || exit_code=1
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        check_env_files || exit_code=1
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        check_wallet_balance || exit_code=1
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        check_dfx_configuration || exit_code=1
    fi
    
    # Final report
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    if [[ $exit_code -eq 0 ]]; then
        if [[ "$DANGER_LEVEL" == "DANGER" ]]; then
            echo "║  ⚠️  SAFETY CHECK PASSED - BUT MAINNET OPERATION                  ║"
            echo "║  ⚠️  EXPLICIT USER APPROVAL REQUIRED                              ║"
        else
            echo "║  ✅ ALL SAFETY CHECKS PASSED                                       ║"
        fi
    else
        echo "║  ❌ SAFETY CHECKS FAILED                                           ║"
    fi
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    return $exit_code
}

# =============================================================================
# INTERACTIVE CONFIRMATION (for mainnet)
# =============================================================================

require_user_confirmation() {
    if [[ "$DANGER_LEVEL" != "DANGER" ]]; then
        return 0  # No confirmation needed for local/staging
    fi
    
    echo ""
    log_critical "════════════════════════════════════════════════════════════"
    log_critical "  MAINNET OPERATION REQUIRES EXPLICIT CONFIRMATION"
    log_critical "════════════════════════════════════════════════════════════"
    echo ""
    log_critical "You are about to perform an operation on MAINNET (ic)"
    log_critical "This will use REAL ICP and affect PRODUCTION canisters:"
    echo ""
    
    for canister in "${!PROD_CANISTER_IDS[@]}"; do
        echo "  • $canister: ${PROD_CANISTER_IDS[$canister]}"
    done
    
    echo ""
    log_critical "ARE YOU SURE YOU WANT TO PROCEED?"
    echo ""
    
    read -p "Type 'YES' to confirm: " confirm
    
    if [[ "$confirm" != "YES" ]]; then
        log_error "Confirmation failed - operation cancelled"
        return 1
    fi
    
    log_success "User confirmed - proceeding with mainnet operation"
    return 0
}

# =============================================================================
# MAIN ENTRY
# =============================================================================

main() {
    run_safety_checks "$1"
    local check_result=$?
    
    if [[ $check_result -eq 0 ]]; then
        require_user_confirmation
        return $?
    fi
    
    return $check_result
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
