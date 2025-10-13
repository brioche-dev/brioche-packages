# Get project metadata
mut project = $env.project
  | from json

# Retrieve the latest release information from Gitea
let releases = http get $'https://gitea.com/api/v1/repos/($env.repoOwner)/($env.repoName)/releases'

# Extract the version(s)
let releasesInfo = $releases
  | each {|release|
    let parsedTag = $release.tag_name
      | parse --regex $env.matchTag

    # If no tag is matched, a nil value will be returned
    # and this value will be ignored by 'each'
    if ($parsedTag | length) != 0 {
      { version: $parsedTag.0.version }
    }
  }
  | sort-by --natural version

if ($releasesInfo | length) == 0 {
  error make { msg: $'No tag did match regex ($env.matchTag)' }
}

let latestReleaseInfo = $releasesInfo
  | last

mut version = $latestReleaseInfo.version

if $env.normalizeVersion == "true" {
  $version = $version
    | str replace --all --regex "(-|_)" "."
}

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

# Return back the project metadata encoded as JSON
$project
  | to json
