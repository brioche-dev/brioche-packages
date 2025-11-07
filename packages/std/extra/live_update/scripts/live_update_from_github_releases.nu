# Retrieve the most recent releases from GitHub
# Include GitHub Token if present (for increased rate limits)
mut gh_headers = []
if ($env.GITHUB_TOKEN? | default "") != "" {
  $gh_headers ++= [Authorization $'Bearer ($env.GITHUB_TOKEN)']
}

let releases = http get --allow-errors --headers $gh_headers $'https://api.github.com/repos/($env.repoOwner)/($env.repoName)/releases'
  # Check the response status
  | metadata access {|meta|
    match $meta.http_response.status {
      200 => {
        # Success
      }
      401 => {
        error make { msg: $'Unauthorized access to GitHub API' }
      }
      403 | 429 => {
        error make { msg: $'GitHub API rate limit exceeded' }
      }
      _ => {
        error make { msg: $'Failed to call GitHub API: ($meta.http_response.status)' }
      }
    }
  }
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

if ($project | get extra?.otherVersions?) != null {
  # Ensure the newest version is in the list of other versions, then
  # update the metadata of each other version
  let otherVersions = $project.extra.otherVersions
    | items {|key, value|
      let latestVersion = $releases
        | where ($it.version | str starts-with $key)
        | last
        | get version

      { $key: $latestVersion }
    }
    | into record
    | sort -r

  $project = $project
    | update extra.otherVersions $otherVersions
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
