# `nodejs_frontend`

A small project that uses Vite + Node.js to built a React-based SPA.

## Usage

- Output the static site with `brioche build -p ./examples/nodejs_frontend -e staticSite -o dist`. This will give you a directory that can be uploaded to a static site host, like GitHub Pages or an S3-compatible host.
- Test the static site locally with `brioche run -p ./examples/nodejs_frontend`. This will build the static site then serve it with [miniserve](https://github.com/svenstaro/miniserve). By default, it will run on <http://localhost:8080>
