# Get project metadata
mut project = $env.project
  | from json

# Retrieve the most recent releases from crates.io registry
let releaseInfo = http get $'https://crates.io/api/v1/crates/($env.crateName)'

# Extract the latest version
let version = $releaseInfo
  | get crate.max_version

let parsedVersion = $version
  | parse --regex $env.matchVersion
if ($parsedVersion | length) == 0 {
  error make { msg: $'Latest release ($version) did not match regex ($env.matchVersion)' }
}

let version = $parsedVersion.0.version?
if $version == null {
  error make { msg: $'Regex ($env.matchVersion) did not include version when matching latest release ($version)' }
}

$project = $project
  | update version $version

# Return back the project metadata encoded as JSON
$project
  | to json
