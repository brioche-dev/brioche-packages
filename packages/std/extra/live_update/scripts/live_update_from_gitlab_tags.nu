# Get project metadata
mut project = $env.project
  | from json

# Retrieve the most recent tags from GitLab
let tags = http get $'https://gitlab.com/api/v4/projects/($env.repoOwner)%2F($env.repoName)/repository/tags'
  # Extract the tag(s)
  | get name
  | each {|name|
    $name
      | parse --regex $env.matchTag
      | get -o 0
  }
  | sort-by --natural version

if ($tags | length) == 0 {
  error make { msg: $'No tag did match regex ($env.matchTag)' }
}

# Get the latest tag
mut latestTag = $tags
  | last

# Get the version
mut version = $latestTag
  | get version

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
