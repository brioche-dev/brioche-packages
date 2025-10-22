# Get project metadata
mut project = $env.project
  | from json

# Retrieve the most recent tags from GitHub
# Include GitHub Token if present (for increased rate limits)
mut gh_headers = []
if ($env.GITHUB_TOKEN? | default "") != "" {
  $gh_headers ++= [Authorization $'Bearer ($env.GITHUB_TOKEN)']
}

let tags = http get --allow-errors --headers $gh_headers $'https://api.github.com/repos/($env.repoOwner)/($env.repoName)/git/matching-refs/tags'
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

# Exract the tag(s)
let parsedTags = $tags
  | get ref
  | each {|ref|
    $ref
      # 'refs/tags/' is the prefix for tags in GitHub API responses
      # and is followed by the tag name, remove it
      | str substring 10..-1
      | parse --regex $env.matchTag
      | get -o 0
  }
  | sort-by --natural version

if ($parsedTags | length) == 0 {
  error make { msg: $'No tag did match regex ($env.matchTag)' }
}

# Extract the latest version
mut version = $parsedTags
  | last
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

if ($project | get extra?.otherVersions?) != null {
  # Ensure the newest version is in the list of other versions, then
  # update the metadata of each other version
  let otherVersions = $project.extra.otherVersions
    | items {|key, value|
      let latestVersion = $parsedTags
        | where { |parsedTag| $parsedTag.version | str starts-with $key }
        | last
        | get version

      { $key: $latestVersion }
    }
    | into record
    | sort -r

  $project = $project
    | update extra.otherVersions $otherVersions
}

# Return back the project metadata encoded as JSON
$project
  | to json
