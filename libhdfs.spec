Name:           libhdfs
Version:        3.3.6
Release:        1%{?dist}
Summary:        Native C/C++ API for HDFS (Hadoop Distributed File System)

License:        Apache-2.0
URL:            https://github.com/jojochuang/libhdfs
Source0:        %{name}-%{version}.tar.gz

BuildArch:      %{_target_cpu}

%description
The Hadoop Distributed File System (HDFS) C/C++ API library provides
native C/C++ bindings for accessing HDFS file systems. This package
contains the shared and static libraries for developing applications
that use HDFS.

%package        devel
Summary:        Development files for %{name}
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description    devel
The %{name}-devel package contains header files for developing
applications that use %{name}.

%prep
%setup -q

%build
# Pre-built binaries, no build step required

%install
rm -rf $RPM_BUILD_ROOT

# Create directories
install -d $RPM_BUILD_ROOT%{_libdir}

# Determine architecture directory
%ifarch x86_64
ARCH_DIR="x86"
%endif
%ifarch aarch64
ARCH_DIR="arm64"
%endif

# Install shared library and create symlinks
install -m 755 ${ARCH_DIR}/libhdfs.so.0.0.0 $RPM_BUILD_ROOT%{_libdir}/
ln -sf libhdfs.so.0.0.0 $RPM_BUILD_ROOT%{_libdir}/libhdfs.so.0
ln -sf libhdfs.so.0.0.0 $RPM_BUILD_ROOT%{_libdir}/libhdfs.so

# Install static library
install -m 644 ${ARCH_DIR}/libhdfs.a $RPM_BUILD_ROOT%{_libdir}/

%files
%{_libdir}/libhdfs.so.*

%files devel
%{_libdir}/libhdfs.so
%{_libdir}/libhdfs.a

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%changelog
* Fri Sep 27 2024 GitHub Copilot <copilot@github.com> - 3.3.6-1
- Initial RPM package for libhdfs
- Support for x86_64 and aarch64 architectures
- Install libraries to /usr/lib64 (or appropriate libdir)