# std Changelog

All notable changes to the `std` package will be documented in this file.

The `std` package is not yet considered stable and doesn't currently assign version numbers to releases, so changes are documented by date. You are encouraged to use version control with the `brioche.lock` lockfile to ensure the version of the `std` package used stays consistent within your Brioche projects.

## 2024-07-12 (Breaking)

PR: [#26](https://github.com/brioche-dev/brioche-packages/pull/58)

> **Note**: This change leads to a rebuild for all downstream packages

### Breaking

- Replace `std.autowrap()` function with new `std.autopack()` function.
    - This new function is similar to the removed one, but it has more options, supports packing scripts, supports repacking already-packed files, and supports using glob patterns

## 2024-06-25 (Breaking)

PR: [#25](https://github.com/brioche-dev/brioche-packages/pull/25)

### Breaking

- Remove `Recipe.cast()` utility method
    - For process recipes, `.toFile()` / `.toDirectory()` / `.toSymlink()` can be used
    - In general, `std.castToFile()` / `std.castToDirectory()` / `std.castToSymlink()` can be used
- Update `Directory.peel()` method to return `Recipe<Directory>` instead of `Recipe`. In every case used so far, this result was immediately casted to a directory, so casting is no longer required now
- Change `std.outputPath`, `std.workDir`, etc. to no longer be symbols. These are still exported constants, but `===` equality comparisons will no longer work as expected
- Remove Python and OpenSSL from `std.toolchain()`. Both will be moved to independent packages

### Changed

- Fix type compatibility issues when mixing multiple versions of the `std` package in a single Brioche project (e.g. when a different version of `std` is used by a direct dependency)
- Set `$CPATH` env var when using `std.tools()` / `std.toolchain()` as dependencies

## 2024-06-13

PR: [#24](https://github.com/brioche-dev/brioche-packages/pull/24)

### Changed

- Update `std.ociContainerImage()` to produce OCI container images compatible with Docker (via `docker load`)

## 2024-06-10

PR: [#22](https://github.com/brioche-dev/brioche-packages/pull/22)

### Added

- Add `std.BRIOCHE_VERSION` export
- Add `std.collectReferences()` function. Requires Brioche >=0.1.1

### Changed

- Improve `std.ociContainerImage()` to improve image sizes when on Brioche >=0.1.1 (it uses `std.collectReferences()` now when possible)

## 2024-06-03

- Initial release date
