# LFS Script Library

This directory contains utility libraries for the Linux From Scratch (LFS) build scripts.

## Files in this library:

### common.sh
**Purpose**: Core utility functions used across all LFS scripts
**Contents**:
- Color-coded logging functions (log_info, log_warn, log_error, log_success)
- Environment validation (check_root, check_lfs_env)
- Command availability checking (check_command)
- Script header display functions

### package.sh
**Purpose**: Package management utilities for downloading and handling source packages
**Contents**:
- download_package() - Downloads source packages from URLs
- verify_checksum() - Verifies MD5/SHA256 checksums of downloaded files
- extract_package() - Extracts various archive formats (tar.gz, tar.bz2, tar.xz, zip)

### build.sh
**Purpose**: Build process utilities for compiling and installing packages
**Contents**:
- configure_package() - Runs ./configure with appropriate options
- build_package() - Compiles packages using make with parallel jobs
- install_package() - Installs packages with optional DESTDIR
- test_package() - Runs package test suites
- clean_build() - Cleans build artifacts
- full_build() - Complete build process (configure → build → test → install)

### system.sh
**Purpose**: System configuration and setup utilities for LFS environment
**Contents**:
- check_host_requirements() - Verifies required build tools are available
- check_versions() - Displays versions of key build tools
- setup_lfs_user() - Creates and configures the LFS build user
- mount_lfs() - Mounts the LFS partition
- create_lfs_directories() - Creates essential LFS directory structure

## Usage

To use these libraries in your LFS scripts:

```bash
#!/bin/bash
# Source the required library
source "$(dirname "$0")/lib/common.sh"
source "$(dirname "$0")/lib/package.sh"

# Use the functions
log_info "Starting package build..."
download_package "https://example.com/package.tar.gz"
extract_package "/sources/package.tar.gz"
```

## Dependencies

These scripts require:
- Bash 4.0+
- Standard GNU tools (wget, tar, make, etc.)
- Proper LFS environment setup with $LFS variable set