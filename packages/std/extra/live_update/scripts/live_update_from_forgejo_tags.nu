# Retrieve the most recent tags from Forgejo
let tags = http get $'($env.baseUrl)/api/v1/repos/($env.repoOwner)/($env.repoName)/tags'
  # Extract the tag(s)
  | get name
  | each {|name|
    $name
      | parse --regex $env.matchTag
      | into record
  }
  | where (($it | get -o version) | is-not-empty)
  | sort-by --natural version

if ($tags | is-empty) {
  error make { msg: $'No tag does match regex ($env.matchTag)' }
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

# Return back the project metadata encoded as JSON
$project
  | to json
