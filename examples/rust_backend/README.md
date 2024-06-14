# `rust_backend`

A small Rust example project that starts a server with [Axum](https://github.com/tokio-rs/axum)

See [`project.bri`](./project.bri) for the Brioche build definition.

## Usage

- Start the server by running `brioche run -p ./examples/rust_backend`. listens on `http://localhost:8000`
- Make a request to the server using Curl: `curl -v 'http://localhost:8000'`
- Build a container: `brioche build -p ./examples/rust_backend -e container -o container.tar`
- Run the container with Podman / Docker (example with Podman shown below):
    1. Load the container with `podman load -i container.tar`. Podman will print the digest of the image, like `sha256:xxxxx`
    2. Run the container with `podman run --rm -p 8000:8000 'sha256:xxxx'` (using the same digest from (1))
