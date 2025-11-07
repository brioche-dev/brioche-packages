# Retrieve the latest release from npm registry
let latestReleaseInfo = http get $'https://registry.npmjs.org/($env.packageName)/latest'

let parsedVersion = $latestReleaseInfo
  | get version
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
