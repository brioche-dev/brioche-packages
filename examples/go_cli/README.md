# `go_cli`

A small Go CLI tool that waits for a specified duration (default 1 second) then exits, showing a progress bar while waiting.

See [`project.bri`](./project.bri) for the Brioche build definition.

## Usage

- Run the CLI tool with `brioche run -p ./examples/go_cli`.
    - View usage by running `brioche run -p ./examples/go_cli -- --help`
    - Set a different duration (e.g. 5 seconds) by running `brioche run -p ./examples/go_cli -- -wait 5s`
- Output the CLI tool to a directory with `brioche build -p ./examples/go_cli -o output`
- Install the CLI tool by running `brioche install -p ./examples/go_cli`
