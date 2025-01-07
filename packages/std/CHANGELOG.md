# std Changelog

All notable changes to the `std` package will be documented in this file.

The `std` package is not yet considered stable and doesn't currently assign version numbers to releases, so changes are documented by date. You are encouraged to use version control with the `brioche.lock` lockfile to ensure the version of the `std` package used stays consistent within your Brioche projects.

## 2025-01-07

PR: [#156](https://github.com/brioche-dev/brioche-packages/pull/156)

### Changed

- Added new variant to `std.Platform` type: `aarch64-linux`
- Fix `bin/ld.bfd` in `std.toolchain()` to call the correct linker (previously, it would still call gold instead of the libbfd linker)
- Wrap `bin/strip` in `std.toolchain()` to handle stripping [packed executables](https://brioche.dev/docs/how-it-works/packed-executables/) properly
- Restructure unwrapped binaries in `std.toolchain()` for `ld` / `cc`. Instead of adding `-orig` as a suffix, they now use the prefix `.brioche-`
- Fix absolute paths in `lib/libacl.la` in `std.toolchain()` (other libtool libraries remain unchanged)

## 2024-10-12

PR: [#122](https://github.com/brioche-dev/brioche-packages/pull/122)

### Breaking

The inputs for `std.process()` for enabling unsafe features has been changed. Additionally, the `unsafe` flag is now conditionally set on the process recipe itself, making it easier to conditionally enable unsafe for processes. Here's a minimal example demonstrating the change:

```typescript
// Before
std.process({
  command: "/bin/sh",
  args: ["-c", "echo 'Hello'"],
  unsafe: true,
  networking: true,
});

// After
std.process({
  command: "/bin/sh",
  args: ["-c", "echo 'Hello'"],
  unsafe: {
    networking: false,
  },
});
```

### Added

- Added `std.ProcessUnsafeOptions` type export. This is used by both the `unsafe` option for `std.process()` and the `.unsafe()` method on the `std.Process` type

## 2024-10-06

PR: [#118](https://github.com/brioche-dev/brioche-packages/pull/118)

### Changed

- Fixed typo in `$PERL5LIB` when using `std.toolchain()` as a dependency
- Fixed broken symlinks for several library files in `std.toolchain()` under `lib/`
- Patched pkg-config files in `std.toolchain()` to replace absolute paths with relative paths

## 2024-10-05

PRs:
- [#115](https://github.com/brioche-dev/brioche-packages/pull/115)
- [#116](https://github.com/brioche-dev/brioche-packages/pull/116)

### Added

- Added `std.withRunnable(recipe, options)` to make a recipe runnable by adding a `brioche-run` executable. The options specify the command, args, and env to run
- Added `std.addRunnable(recipe, path, options)`, which is just like `std.withRunnable()`, except it takes the path for the executable (instead of just `brioche-run`)

### Fixed

- Fix bison in `std.toolchain()` by setting `$BISON_PKGDATADIR` by default

## 2024-10-04

PR: [#114](https://github.com/brioche-dev/brioche-packages/pull/114)

### Changed

- Updated `std.toolchain()` to set more env vars for autotools builds. Autotools builds should now work more reliably without any manual configuration

## 2024-09-28

PR: [#110](https://github.com/brioche-dev/brioche-packages/pull/110)

### Breaking

`std.setEnv()` now takes a different input. To get the same behavior as before of appending env vars, each one needs to be wrapped in an object with the key `append`, like so:

```typescript
// Previously
/*
std.setEnv(recipe, {
  FOO: { path: "foo" },
  BAR: [{ path: "bar" }, { path: "baz" }],
});
*/

// Now
std.setEnv(recipe, {
  FOO: { append: [{ path: "foo" }] },
  BAR: { append: [{ path: "bar" }, { path: "baz" }] },
});
```

### Changed

- Updated `std.setEnv()` to support new "fallback" env vars (**requires Brioche v0.1.2 or later**):
    - `VAR: { fallback: { path: "some/path" } }`: If `$VAR` is not set, set it to the absolute path for `some/path`
    - `VAR: { fallback: { value: "1" } }`: If `$VAR` is not set, set it to the value `1`
- Update `std.toolchain()` to set several env vars for automake/autoconf by default
- Re-pack `std.tools()` and `std.toolchain()` to make sure they all use the final built version of all libraries. This should also help shrink their artifacts

## 2024-09-26

PRs:
- [#75](https://github.com/brioche-dev/brioche-packages/pull/75)
- [#104](https://github.com/brioche-dev/brioche-packages/pull/104)
- [#105](https://github.com/brioche-dev/brioche-packages/pull/105)
- [#108](https://github.com/brioche-dev/brioche-packages/pull/108)

> **Note**: This version of `std` requires Brioche v0.1.2 or greater. Run `brioche self-update` for installation instructions

### Added

- Add `Brioche.download(...)` function. This function takes a string literal, pins the download's hash in the `brioche.lock` lockfile, and returns a recipe. It's like `std.download()` except the hash doesn't need to be manually entered
- Add `Brioche.gitRef({ repository, ref })` function. This function takes a string literal repository URL and a string literal git ref (branch or tag name), then records and returns the commit hash for that ref in the `brioche.lock` lockfile. This is designed to be used with the `gitCheckout` function from the `git` package, so a git branch or tag name can be supplied instead of manually entering a git commit hash.
- Add `std.glob()` function. Takes a directory recipe and an array of glob patterns, and filters the recipe to only the paths that match one or more patterns.

## 2024-08-31

PR: [#106](https://github.com/brioche-dev/brioche-packages/pull/106)

### Added

- Add new `std.semverMatches(version, constraint)` function. Returns true if the given version meets the provided semver constraint. Example: `std.semverMatches("1.2.5", ">=1.1.0")` returns true

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
