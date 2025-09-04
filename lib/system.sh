#!/bin/bash
# system.sh - System configuration utilities for LFS
# Functions for system setup, user management, and environment configuration

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Check system requirements
check_host_requirements() {
    log_info "Checking host system requirements..."
    
    local required_tools=(
        "bash" "binutils" "bison" "gawk" "gcc" "g++"
        "make" "patch" "perl" "python3" "sed" "tar"
        "texinfo" "xz"
    )
    
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! check_command "$tool"; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -eq 0 ]]; then
        log_success "All required tools are available"
        return 0
    else
        log_error "Missing required tools: ${missing_tools[*]}"
        return 1
    fi
}

# Check version requirements
check_versions() {
    log_info "Checking tool versions..."
    
    # Check bash version
    local bash_version=$(bash --version | head -n1 | grep -o '[0-9]\+\.[0-9]\+')
    log_info "Bash version: $bash_version"
    
    # Check GCC version
    if command -v gcc &>/dev/null; then
        local gcc_version=$(gcc --version | head -n1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
        log_info "GCC version: $gcc_version"
    fi
    
    # Check make version
    if command -v make &>/dev/null; then
        local make_version=$(make --version | head -n1 | grep -o '[0-9]\+\.[0-9]\+')
        log_info "Make version: $make_version"
    fi
}

# Setup LFS user environment
setup_lfs_user() {
    local lfs_user="${1:-lfs}"
    
    log_info "Setting up LFS user: $lfs_user"
    
    # Create user if it doesn't exist
    if ! id "$lfs_user" &>/dev/null; then
        if sudo useradd -s /bin/bash -g lfs -m -k /dev/null "$lfs_user"; then
            log_success "Created LFS user: $lfs_user"
        else
            log_error "Failed to create LFS user"
            return 1
        fi
    else
        log_info "LFS user already exists"
    fi
    
    # Setup user environment
    cat > "/tmp/lfs_profile" << 'EOF'
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF
    
    cat > "/tmp/lfs_bashrc" << 'EOF'
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
EOF
    
    if sudo cp "/tmp/lfs_profile" "/home/$lfs_user/.bash_profile" && \
       sudo cp "/tmp/lfs_bashrc" "/home/$lfs_user/.bashrc" && \
       sudo chown "$lfs_user:lfs" "/home/$lfs_user/.bash_profile" "/home/$lfs_user/.bashrc"; then
        log_success "LFS user environment configured"
        rm -f "/tmp/lfs_profile" "/tmp/lfs_bashrc"
        return 0
    else
        log_error "Failed to configure LFS user environment"
        rm -f "/tmp/lfs_profile" "/tmp/lfs_bashrc"
        return 1
    fi
}

# Mount LFS filesystem
mount_lfs() {
    local lfs_partition="$1"
    local lfs_mount="${2:-/mnt/lfs}"
    
    if [[ -z "$lfs_partition" ]]; then
        log_error "LFS partition not specified"
        return 1
    fi
    
    log_info "Mounting LFS partition $lfs_partition to $lfs_mount"
    
    # Create mount point if it doesn't exist
    if [[ ! -d "$lfs_mount" ]]; then
        sudo mkdir -p "$lfs_mount"
    fi
    
    # Mount the partition
    if sudo mount "$lfs_partition" "$lfs_mount"; then
        log_success "LFS partition mounted successfully"
        return 0
    else
        log_error "Failed to mount LFS partition"
        return 1
    fi
}

# Create essential directories
create_lfs_directories() {
    local lfs_root="${1:-/mnt/lfs}"
    
    log_info "Creating essential LFS directories in $lfs_root"
    
    local directories=(
        "etc" "var" "usr/bin" "usr/lib" "usr/sbin"
        "usr/include" "usr/share/man/man1" "usr/share/man/man2"
        "usr/share/man/man3" "usr/share/man/man4" "usr/share/man/man5"
        "usr/share/man/man6" "usr/share/man/man7" "usr/share/man/man8"
        "var/log" "var/mail" "var/spool" "lib/firmware"
        "media" "mnt" "opt" "run" "srv" "sys"
        "tmp" "root" "home" "boot" "dev"
        "proc" "sources" "tools" "cross-tools"
    )
    
    for dir in "${directories[@]}"; do
        if sudo mkdir -p "$lfs_root/$dir"; then
            log_info "Created directory: $dir"
        else
            log_error "Failed to create directory: $dir"
            return 1
        fi
    done
    
    # Set proper permissions
    sudo chmod 1777 "$lfs_root/tmp"
    sudo chmod 755 "$lfs_root"
    
    log_success "Essential directories created"
    return 0
}