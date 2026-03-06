# Retrieve the crate information from crates.io registry
let versions = http get $'https://crates.io/api/v1/crates/($env.crateName)'
  # Extract the version(s)
  | get versions
  | where { $in.yanked == false }
  | each {|version|
    $version.num
      | parse --regex $env.matchVersion
      | into record
  }
  | where (($it | get -o version) | is-not-empty)
  | sort-by --natural version

if ($versions | is-empty) {
  error make { msg: $'No version matches regex ($env.matchVersion)' }
}

# Get the latest version
let version = $versions
  | last
  | get version

# Get project metadata, and update it
mut project = $env.project
  | from json

$project = $project
  | update version $version

# Return back the project metadata encoded as JSON
$project
  | to json
