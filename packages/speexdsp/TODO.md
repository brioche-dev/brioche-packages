# TODO

## Add FFTW3 as optional dependency

Add `fftw3` as an optional dependency for better FFT performance.

Currently, speexdsp uses the built-in `smallft` implementation. Adding FFTW3 support would require:

1. Create a `fftw3` package in brioche-packages
2. Add `fftw3` to dependencies
3. Configure with `--with-fft=fftw3` flag
