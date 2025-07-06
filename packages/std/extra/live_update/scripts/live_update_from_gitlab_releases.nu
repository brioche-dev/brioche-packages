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

let version = $parsedTagName.0.version?
if $version == null {
  error make { msg: $'Regex ($env.matchTag) did not include version when matching latest release tag ($tagName)' }
}

$project = $project
  | update version $version

# Return back the project metadata encoded as JSON
$project
  | to json
