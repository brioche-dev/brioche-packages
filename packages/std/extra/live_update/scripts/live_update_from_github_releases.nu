# Get project metadata
mut project = $env.project
  | from json

# Retrieve the latest release information from GitHub
# Include GitHub Token if present (for increased rate limits)
mut gh_headers = []
if ($env.GITHUB_TOKEN? | default "") != "" {
  $gh_headers ++= [Authorization $'Bearer ($env.GITHUB_TOKEN)']
}

let httpResponse = http get --full --allow-errors --headers $gh_headers $'https://api.github.com/repos/($env.repoOwner)/($env.repoName)/releases'
match $httpResponse.status {
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
    error make { msg: $'Failed to call GitHub API: ($httpResponse.status)' }
  }
}
let releases = $httpResponse.body

# Extract the version(s)
let releasesInfo = $releases
  | where {|release| ($env.includePrerelease == "true") or (not $release.prerelease) }
  | each {|release|
    let parsedTag = $release.tag_name
      | parse --regex $env.matchTag

    # If no tag is matched, a nil value will be returned
    # and this value will be ignored by 'each'
    if ($parsedTag | length) != 0 {
      { version: $parsedTag.0.version, created_at: $release.created_at }
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

if ($project | get extra?.otherVersions?) != null {
  # Ensure the newest version is in the list of other versions, then
  # update the metadata of each other version
  let otherVersions = $project.extra.otherVersions
    | items {|key, value|
      let latestVersion = $releasesInfo
        | where { |releaseInfo| $releaseInfo.version | str starts-with $key }
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
