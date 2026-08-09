# Build

The default build compiles OpenSSL, APR, APR-util, httpd, and nghttp3 from the repository submodules. This is the supported path when system packages do not meet the required httpd module magic number.

```sh
git submodule update --init
git submodule update --init --recursive dependencies/nghttp3
cmake -B build
cmake --build build
```

Only nghttp3 needs its own submodule (`lib/sfparse`). Recursing everywhere also clones OpenSSL's eleven external-test submodules, which the build never uses.

The module is written to `build/lib/mod_http3.so`.

## Requirements

The versions below are what the submodule build produces; supply your own with
the `WITH_*` options only if they meet these minimums.

| Dependency | Minimum |
| --- | --- |
| OpenSSL | 3.5.0 with QUIC support |
| Apache httpd | MMN 20211221 |
| APR | 1.7.0 |
| APR-util | 1.6.0 |
| nghttp3 | 1.18.0 |

Distribution-provided httpd packages usually have an older MMN and are rejected. Use the default source build or provide compatible custom prefixes.

APR-util needs expat and httpd needs PCRE2. Neither is a submodule, because
neither is a dependency of mod_http3: they belong to the server stack, and both
are located with `find_package`, so they come from wherever the platform keeps
its packages.

| Platform | Where they come from |
| --- | --- |
| Debian, Ubuntu | `apt install libexpat1-dev libpcre2-dev` |
| Fedora, RHEL | `dnf install expat-devel pcre2-devel` |
| Windows | `vcpkg install expat:x64-windows pcre2:x64-windows` |

## Windows

Windows builds with MSVC, which is what APR, APR-util and httpd write their own
Windows CMake builds for. Using it is what keeps `dependencies/` unpatched, so
there is no cross-compiler path from Linux: build it on Windows, or let the
`windows` CI job do it. Configure with vcpkg's toolchain file so the sub-builds
resolve the packages above:

```sh
cmake -B build -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$VCPKG_INSTALLATION_ROOT/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_TARGET_TRIPLET=x64-windows
cmake --build build
```

## Custom Prefixes

```sh
git submodule update --init dependencies/nghttp3
cmake -B build \
    -DWITH_SSL=/opt/openssl \
    -DWITH_HTTPD=/opt/httpd \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTS=OFF
cmake --build build
```

Set `WITH_APR` and `WITH_APU` when APR and APR-util are not part of the httpd prefix. See the [full installation reference](https://github.com/machine-moon/mod_http3/blob/trunk/INSTALL) for package builds and every CMake option.
