# Retrieve the most recent releases from Go proxy registry
let releases = http get $'https://proxy.golang.org/($env.moduleName)/@v/list'
  | lines
  # Extract the version(s)
  | each {|release|
    $release
      | parse --regex $env.matchVersion
      | into record
  }
  | where (($it | get -o version) | is-not-empty)
  | sort-by --natural version

if ($releases | is-empty) {
  error make { msg: $'No version does match regex ($env.matchVersion)' }
}

# Get the latest release
let latestReleaseInfo = $releases
  | last

# Get the version
let version = $latestReleaseInfo.version

# Get project metadata, and update it
mut project = $env.project
  | from json

$project = $project
  | update version $version

# Return back the project metadata encoded as JSON
$project
  | to json
