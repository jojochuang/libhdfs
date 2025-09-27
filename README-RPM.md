# libhdfs RPM Packaging

This repository contains scripts to create RPM packages for libhdfs (Hadoop Distributed File System C/C++ library) for both x86_64 and aarch64 architectures.

## Prerequisites

Before building RPM packages, ensure you have the following tools installed:

### Red Hat/CentOS/Fedora:
```bash
sudo yum install rpm-build rpmdevtools
# or on newer systems:
sudo dnf install rpm-build rpmdevtools
```

### Ubuntu/Debian:
```bash
sudo apt-get install rpm
```

## Package Contents

The repository contains pre-built libhdfs binaries for two architectures:

- **x86/** - x86_64 binaries
  - `libhdfs.a` - Static library
  - `libhdfs.so` - Symbolic link to shared library
  - `libhdfs.so.0.0.0` - Shared library

- **arm64/** - aarch64 binaries  
  - `libhdfs.a` - Static library
  - `libhdfs.so` - Symbolic link to shared library
  - `libhdfs.so.0.0.0` - Shared library

## Building RPM Packages

### Using the Build Script

The `build-rpm.sh` script provides a convenient way to build RPM packages:

```bash
# Build for current architecture
./build-rpm.sh

# Build for specific architecture
./build-rpm.sh --arch x86_64
./build-rpm.sh --arch aarch64

# Build for both architectures
./build-rpm.sh --arch both

# Clean build and then build
./build-rpm.sh --clean
```

### Using Make

Alternatively, you can use the provided Makefile:

```bash
# Build for current architecture
make rpm

# Build for specific architectures
make rpm-x86_64
make rpm-aarch64
make rpm-both

# Clean and build
make clean rpm
```

## Package Installation

The libraries will be installed to the standard system library directory:

- On 64-bit systems: `/usr/lib64/`
- Shared libraries: `libhdfs.so`, `libhdfs.so.0`, `libhdfs.so.0.0.0`
- Static library: `libhdfs.a`

### Installing the RPM

Once built, install the package with:

```bash
# Install the main package
sudo rpm -ivh ~/rpmbuild/RPMS/x86_64/libhdfs-3.3.6-1.*.x86_64.rpm

# Install development files (optional)
sudo rpm -ivh ~/rpmbuild/RPMS/x86_64/libhdfs-devel-3.3.6-1.*.x86_64.rpm
```

### Packages Created

The build process creates two packages:

1. **libhdfs** - Runtime libraries
   - Contains shared libraries (`libhdfs.so.*`)
   - Required for running applications that use libhdfs

2. **libhdfs-devel** - Development files
   - Contains static library (`libhdfs.a`) 
   - Contains development symlink (`libhdfs.so`)
   - Required for compiling applications against libhdfs

## Package Information

- **Name**: libhdfs
- **Version**: 3.3.6
- **License**: Apache-2.0
- **Architecture Support**: x86_64, aarch64
- **Description**: Native C/C++ API for HDFS (Hadoop Distributed File System)

## Troubleshooting

### Missing Dependencies

If you get errors about missing dependencies, install the required packages:

```bash
# Red Hat/CentOS/Fedora
sudo yum install rpm-build rpmdevtools

# Check if rpmbuild is available
which rpmbuild
```

### Architecture Issues

The build script automatically detects your architecture, but you can force building for a specific architecture using the `--arch` parameter.

### Build Directory Issues

If you encounter issues with the RPM build directories:

```bash
# Clean everything and start fresh
make distclean
make rpm
```

## Files Structure

```
.
├── arm64/                  # aarch64 binaries
│   ├── libhdfs.a
│   ├── libhdfs.so -> libhdfs.so.0.0.0
│   └── libhdfs.so.0.0.0
├── x86/                    # x86_64 binaries  
│   ├── libhdfs.a
│   ├── libhdfs.so -> libhdfs.so.0.0.0
│   └── libhdfs.so.0.0.0
├── build-rpm.sh           # RPM build script
├── libhdfs.spec           # RPM specification file
├── Makefile               # Build targets
└── README-RPM.md          # This file
```

## Support

For issues related to the RPM packaging, please open an issue in the GitHub repository.