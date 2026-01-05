# rdma_core - Missing Dependencies

This document tracks optional dependencies that are currently not available in Brioche but could enhance the package functionality.

## Missing Dependencies

| CMake Package | Brioche Package | Feature Disabled | Priority |
|---------------|-----------------|------------------|----------|
| `Systemd` (libsystemd) | `systemd` (not available) | Systemd integration | Low |
| `Cython` | `cython` (not available) | Python bindings (pyverbs) | Low |
| `Valgrind` | `valgrind` (not available) | Memory debugging annotations | Low |

## Enabled Dependencies

| CMake Package | Brioche Package | Feature Enabled |
|---------------|-----------------|-----------------|
| `libnl-3.0`, `libnl-route-3.0` | `libnl` | Neighbour resolution for RDMA address resolution |
| `UDev` (libudev) | `libudev_zero` | Device management features |

## Notes

- **libnl**: Enables neighbour resolution for RDMA address resolution. This is useful for RoCE (RDMA over Converged Ethernet) deployments.
- **libudev_zero**: Lightweight libudev implementation that enables device management features.
- **Cython/pyverbs**: Would provide Python bindings for the RDMA libraries. Useful for scripting and testing.
- **Valgrind**: Only needed for development/debugging purposes.

## When to Revisit

Consider adding these dependencies when:
1. Users request specific features that require these dependencies
