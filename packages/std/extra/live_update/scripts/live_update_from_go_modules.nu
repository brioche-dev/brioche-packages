# Get project metadata
mut project = $env.project
  | from json

  # Retrieve the most recent releases from Go proxy registry
let releases = http get $'https://proxy.golang.org/($env.moduleName)/@v/list'
  | lines
  # Extract the version(s)
  | each {|release|
    let parsedVersion = $release
      | parse --regex $env.matchVersion

    # If no version is matched, a nil value will be returned
    # and this value will be ignored by 'each'
    if ($parsedVersion | length) != 0 {
      { version: $parsedVersion.0.version }
    }
  }
  | sort-by --natural version

if ($releases | length) == 0 {
  error make { msg: $'No version did match regex ($env.matchVersion)' }
}

# Get the latest release
let latestReleaseInfo = $releases
  | last

# Get the version
mut version = $latestReleaseInfo.version

$project = $project
  | update version $version

# Return back the project metadata encoded as JSON
$project
  | to json
