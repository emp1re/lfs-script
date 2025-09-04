# lfs-script

A collection of scripts and utilities for building Linux From Scratch (LFS).

## Directory Structure

- `lib/` - Core utility libraries for LFS build scripts
  - `common.sh` - Common utility functions and logging
  - `package.sh` - Package management utilities
  - `build.sh` - Build process utilities
  - `system.sh` - System configuration utilities
  - `README.md` - Detailed documentation of library functions

## Usage

The lib directory contains reusable bash functions that can be sourced into your LFS build scripts to provide common functionality like logging, package management, and build automation.

See `lib/README.md` for detailed documentation of available functions.