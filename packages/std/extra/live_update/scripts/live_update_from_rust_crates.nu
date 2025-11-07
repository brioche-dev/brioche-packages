# Retrieve the crate information from crates.io registry
let crateInfo = http get $'https://crates.io/api/v1/crates/($env.crateName)'

# Get the version
let parsedVersion = $crateInfo
  | get crate.max_version
  | parse --regex $env.matchVersion
  | into record
if (($parsedVersion | get -o version) | is-empty) {
  error make { msg: $'Latest release does not match regex ($env.matchVersion)' }
}

# Get the version
let version = $parsedVersion.version

# Get project metadata, and update it
mut project = $env.project
  | from json

$project = $project
  | update version $version

# Return back the project metadata encoded as JSON
$project
  | to json
