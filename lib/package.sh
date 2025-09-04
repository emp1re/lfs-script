#!/bin/bash
# package.sh - Package management utilities for LFS
# Functions for downloading, verifying, and extracting source packages

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Default source directory
DEFAULT_SOURCES_DIR="${LFS:-/mnt/lfs}/sources"

# Download a package from given URL
download_package() {
    local url="$1"
    local target_dir="${2:-$DEFAULT_SOURCES_DIR}"
    local filename="$(basename "$url")"
    
    log_info "Downloading $filename..."
    
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
    fi
    
    if [[ -f "$target_dir/$filename" ]]; then
        log_warn "File $filename already exists, skipping download"
        return 0
    fi
    
    if wget -P "$target_dir" "$url"; then
        log_success "Downloaded $filename"
        return 0
    else
        log_error "Failed to download $filename"
        return 1
    fi
}

# Verify package checksum
verify_checksum() {
    local file="$1"
    local expected_sum="$2"
    local sum_type="${3:-md5}"
    
    if [[ ! -f "$file" ]]; then
        log_error "File $file does not exist"
        return 1
    fi
    
    log_info "Verifying ${sum_type} checksum for $(basename "$file")..."
    
    local actual_sum
    case "$sum_type" in
        md5)
            actual_sum=$(md5sum "$file" | cut -d' ' -f1)
            ;;
        sha256)
            actual_sum=$(sha256sum "$file" | cut -d' ' -f1)
            ;;
        *)
            log_error "Unsupported checksum type: $sum_type"
            return 1
            ;;
    esac
    
    if [[ "$actual_sum" == "$expected_sum" ]]; then
        log_success "Checksum verification passed"
        return 0
    else
        log_error "Checksum verification failed"
        log_error "Expected: $expected_sum"
        log_error "Actual:   $actual_sum"
        return 1
    fi
}

# Extract package archive
extract_package() {
    local archive="$1"
    local target_dir="${2:-$(dirname "$archive")}"
    
    if [[ ! -f "$archive" ]]; then
        log_error "Archive $archive does not exist"
        return 1
    fi
    
    log_info "Extracting $(basename "$archive")..."
    
    case "$archive" in
        *.tar.gz|*.tgz)
            tar -xzf "$archive" -C "$target_dir"
            ;;
        *.tar.bz2|*.tbz2)
            tar -xjf "$archive" -C "$target_dir"
            ;;
        *.tar.xz|*.txz)
            tar -xJf "$archive" -C "$target_dir"
            ;;
        *.tar)
            tar -xf "$archive" -C "$target_dir"
            ;;
        *.zip)
            unzip -q "$archive" -d "$target_dir"
            ;;
        *)
            log_error "Unsupported archive format: $archive"
            return 1
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        log_success "Extracted $(basename "$archive")"
        return 0
    else
        log_error "Failed to extract $(basename "$archive")"
        return 1
    fi
}