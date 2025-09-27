# Makefile for building libhdfs RPM packages

VERSION = 3.3.6
RELEASE = 1

.PHONY: all rpm rpm-x86_64 rpm-aarch64 rpm-both clean help

# Default target
all: rpm

# Build RPM for current architecture
rpm:
	./build-rpm.sh

# Build RPM for x86_64
rpm-x86_64:
	./build-rpm.sh --arch x86_64

# Build RPM for aarch64  
rpm-aarch64:
	./build-rpm.sh --arch aarch64

# Build RPM for both architectures
rpm-both:
	./build-rpm.sh --arch both

# Clean build directories
clean:
	./build-rpm.sh --clean

# Clean RPM build tree completely
distclean:
	rm -rf $(HOME)/rpmbuild

help:
	@echo "Available targets:"
	@echo "  all         - Build RPM for current architecture (default)"
	@echo "  rpm         - Build RPM for current architecture"
	@echo "  rpm-x86_64  - Build RPM for x86_64 architecture"
	@echo "  rpm-aarch64 - Build RPM for aarch64 architecture"
	@echo "  rpm-both    - Build RPM for both x86_64 and aarch64"
	@echo "  clean       - Clean build directories"
	@echo "  distclean   - Remove entire RPM build tree"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make rpm-x86_64"
	@echo "  make rpm-both"
	@echo "  make clean rpm"