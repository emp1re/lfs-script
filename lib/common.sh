#!/bin/bash
# common.sh - Common utility functions for LFS script
# Provides basic functions used across multiple LFS build scripts

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Check if running in LFS environment
check_lfs_env() {
    if [[ -z "$LFS" ]]; then
        log_error "LFS environment variable is not set"
        log_info "Please set LFS to your LFS mount point"
        exit 1
    fi
    
    if [[ ! -d "$LFS" ]]; then
        log_error "LFS directory $LFS does not exist"
        exit 1
    fi
}

# Verify required commands exist
check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        log_error "Required command '$cmd' is not installed"
        return 1
    fi
}

# Display script header
show_header() {
    local script_name="$1"
    local description="$2"
    
    echo "=================================="
    echo "  $script_name"
    echo "  $description"
    echo "=================================="
    echo
}