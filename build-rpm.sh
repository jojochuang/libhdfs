#!/bin/bash
set -e

# Build script for creating RPM packages for libhdfs
# Supports both x86_64 and aarch64 architectures

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="3.3.6"
RELEASE="1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command -v rpmbuild &> /dev/null; then
        log_error "Missing dependency: rpmbuild"
        log_info "Please install rpm-build package: sudo yum install rpm-build (or equivalent for your distro)"
        exit 1
    fi
}

# Setup RPM build tree
setup_build_tree() {
    log_info "Setting up RPM build tree..."
    
    # Create RPM build directories manually if rpmdev-setuptree is not available
    if command -v rpmdev-setuptree &> /dev/null; then
        rpmdev-setuptree
    else
        log_info "rpmdev-setuptree not found, creating build tree manually..."
        mkdir -p "$HOME/rpmbuild"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
        
        # Create .rpmmacros if it doesn't exist
        if [ ! -f "$HOME/.rpmmacros" ]; then
            cat > "$HOME/.rpmmacros" << EOF
%_topdir %(echo \$HOME)/rpmbuild
EOF
        fi
    fi
}

# Create source tarball
create_source_tarball() {
    local source_dir="libhdfs-${VERSION}"
    local tarball="libhdfs-${VERSION}.tar.gz"
    
    log_info "Creating source tarball: $tarball"
    
    # Create temporary directory structure
    mkdir -p "/tmp/$source_dir"
    
    # Copy source files
    cp -r "$SCRIPT_DIR/arm64" "/tmp/$source_dir/"
    cp -r "$SCRIPT_DIR/x86" "/tmp/$source_dir/"
    cp "$SCRIPT_DIR/libhdfs.spec" "/tmp/$source_dir/"
    
    # Create tarball
    cd /tmp
    tar -czf "$tarball" "$source_dir"
    
    # Move to SOURCES directory
    mv "$tarball" "$HOME/rpmbuild/SOURCES/"
    
    # Cleanup
    rm -rf "/tmp/$source_dir"
    
    log_info "Source tarball created successfully"
}

# Build RPM package for specific architecture
build_rpm() {
    local target_arch="$1"
    
    log_info "Building RPM package for $target_arch..."
    
    # Copy spec file to SPECS directory
    cp "$SCRIPT_DIR/libhdfs.spec" "$HOME/rpmbuild/SPECS/"
    
    # Build the RPM
    rpmbuild --target "$target_arch" -ba "$HOME/rpmbuild/SPECS/libhdfs.spec"
    
    if [ $? -eq 0 ]; then
        log_info "RPM package for $target_arch built successfully"
    else
        log_error "Failed to build RPM package for $target_arch"
        return 1
    fi
}

# Main function
main() {
    log_info "Starting RPM build process for libhdfs"
    
    # Parse command line arguments
    BUILD_ARCH=""
    CLEAN_BUILD=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --arch)
                BUILD_ARCH="$2"
                shift 2
                ;;
            --clean)
                CLEAN_BUILD=true
                shift
                ;;
            --help|-h)
                cat << EOF
Usage: $0 [OPTIONS]

Options:
    --arch ARCH     Build for specific architecture (x86_64, aarch64, or both)
    --clean         Clean build directories before building
    --help, -h      Show this help message

Examples:
    $0                          # Build for current architecture
    $0 --arch x86_64           # Build for x86_64 only
    $0 --arch aarch64          # Build for aarch64 only  
    $0 --arch both             # Build for both architectures
    $0 --clean                 # Clean build and build for current arch

EOF
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Default to current architecture if not specified
    if [ -z "$BUILD_ARCH" ]; then
        BUILD_ARCH=$(uname -m)
    fi
    
    check_dependencies
    setup_build_tree
    
    # Clean build directories if requested
    if [ "$CLEAN_BUILD" = true ]; then
        log_info "Cleaning build directories..."
        rm -rf "$HOME/rpmbuild/BUILD"/*
        rm -rf "$HOME/rpmbuild/BUILDROOT"/*
        rm -rf "$HOME/rpmbuild/RPMS"/*
        rm -rf "$HOME/rpmbuild/SRPMS"/*
    fi
    
    create_source_tarball
    
    # Build for specified architecture(s)
    case "$BUILD_ARCH" in
        x86_64)
            build_rpm "x86_64"
            ;;
        aarch64)
            build_rpm "aarch64"
            ;;
        both)
            build_rpm "x86_64"
            build_rpm "aarch64"
            ;;
        *)
            # Try to build for the detected architecture
            build_rpm "$BUILD_ARCH"
            ;;
    esac
    
    # Show results
    log_info "Build complete!"
    log_info "Built packages:"
    find "$HOME/rpmbuild/RPMS" -name "*.rpm" -exec ls -lh {} \;
    find "$HOME/rpmbuild/SRPMS" -name "*.rpm" -exec ls -lh {} \;
}

# Run main function
main "$@"