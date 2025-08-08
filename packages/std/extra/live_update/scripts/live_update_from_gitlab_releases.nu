# Get project metadata
mut project = $env.project
  | from json

# Retrieve the latest release information from GitLab
let releaseInfo = http get $'https://gitlab.com/api/v4/projects/($env.repoOwner)%2F($env.repoName)/releases/permalink/latest'

# Extract the version
let tagName = $releaseInfo
  | get tag_name

let parsedTagName = $tagName
  | parse --regex $env.matchTag
if ($parsedTagName | length) == 0 {
  error make { msg: $'Latest release tag ($tagName) did not match regex ($env.matchTag)' }
}

mut version = $parsedTagName.0.version

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
