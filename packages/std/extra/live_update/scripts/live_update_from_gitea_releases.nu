# Retrieve the most recent releases from Gitea
let releases = http get $'($env.baseUrl)/api/v1/repos/($env.repoOwner)/($env.repoName)/releases'
  # Extract the version(s)
  | each {|release|
    $release.tag_name
      | parse --regex $env.matchTag
      | into record
      | insert created_at $release.created_at
  }
  | where (($it | get -o version) | is-not-empty)
  | sort-by --natural version

if ($releases | is-empty) {
  error make { msg: $'No tag does match regex ($env.matchTag)' }
}

# Get the latest release
let latestReleaseInfo = $releases
  | last

# Get the version
mut version = $latestReleaseInfo.version

if $env.normalizeVersion == "true" {
  $version = $version
    | str replace --all --regex "(-|_)" "."
}

# Get project metadata, and update it
mut project = $env.project
  | from json

$project = $project
  | update version $version

if ($project | get extra?.versionDash?) != null {
  let $versionDash = $version
    | str replace --all "." "-"

  $project = $project
    | update extra.versionDash $versionDash
}

if ($project | get extra?.versionUnderscore?) != null {
  let $versionUnderscore = $version
    | str replace --all "." "_"

  $project = $project
    | update extra.versionUnderscore $versionUnderscore
}

# Extract the release date (if needed by the project)
if ($project | get extra?.releaseDate?) != null {
  let $createdDate = $latestReleaseInfo
    | get created_at
    | into datetime
    | format date "%Y-%m-%d"

  $project = $project
    | update extra.releaseDate $createdDate
}

# Return back the project metadata encoded as JSON
$project
  | to json
