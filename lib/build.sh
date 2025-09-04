#!/bin/bash
# build.sh - Build utilities for LFS packages
# Functions for configuring, compiling, and installing packages

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Default build settings
DEFAULT_MAKE_JOBS="$(nproc)"
DEFAULT_BUILD_DIR="/tmp/lfs-build"

# Configure package with common options
configure_package() {
    local prefix="${1:-/usr}"
    local additional_opts="${2:-}"
    
    log_info "Configuring package with prefix: $prefix"
    
    local configure_cmd="./configure --prefix=$prefix"
    
    if [[ -n "$additional_opts" ]]; then
        configure_cmd="$configure_cmd $additional_opts"
    fi
    
    log_info "Running: $configure_cmd"
    
    if eval "$configure_cmd"; then
        log_success "Configuration completed"
        return 0
    else
        log_error "Configuration failed"
        return 1
    fi
}

# Build package with make
build_package() {
    local jobs="${1:-$DEFAULT_MAKE_JOBS}"
    local target="${2:-all}"
    
    log_info "Building package with $jobs jobs..."
    
    if make -j"$jobs" "$target"; then
        log_success "Build completed"
        return 0
    else
        log_error "Build failed"
        return 1
    fi
}

# Install package
install_package() {
    local install_root="${1:-}"
    local target="${2:-install}"
    
    if [[ -n "$install_root" ]]; then
        log_info "Installing package to $install_root..."
        if make DESTDIR="$install_root" "$target"; then
            log_success "Installation completed"
            return 0
        else
            log_error "Installation failed"
            return 1
        fi
    else
        log_info "Installing package..."
        if make "$target"; then
            log_success "Installation completed"
            return 0
        else
            log_error "Installation failed"
            return 1
        fi
    fi
}

# Run tests if available
test_package() {
    log_info "Running package tests..."
    
    if make check 2>/dev/null || make test 2>/dev/null; then
        log_success "Tests passed"
        return 0
    else
        log_warn "Tests failed or not available"
        return 1
    fi
}

# Clean build artifacts
clean_build() {
    log_info "Cleaning build artifacts..."
    
    if make clean 2>/dev/null; then
        log_success "Build cleaned"
    else
        log_warn "No clean target available"
    fi
}

# Complete build process: configure, build, test, install
full_build() {
    local prefix="${1:-/usr}"
    local configure_opts="${2:-}"
    local install_root="${3:-}"
    local skip_tests="${4:-false}"
    
    show_header "Full Build Process" "Configure, Build, Test, Install"
    
    # Configure
    if ! configure_package "$prefix" "$configure_opts"; then
        return 1
    fi
    
    # Build
    if ! build_package; then
        return 1
    fi
    
    # Test (optional)
    if [[ "$skip_tests" != "true" ]]; then
        test_package  # Don't fail on test errors
    fi
    
    # Install
    if ! install_package "$install_root"; then
        return 1
    fi
    
    log_success "Full build process completed successfully"
    return 0
}