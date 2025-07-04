# Include GitHub Token if present (for increased rate limits)
mut gh_headers = []
if ($env.GITHUB_TOKEN? | default "") != "" {
  $gh_headers ++= [Authorization $'Bearer ($env.GITHUB_TOKEN)']
}

let tagName = http get --headers $gh_headers $'https://api.github.com/repos/($env.repoOwner)/($env.repoName)/releases/latest'
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

$env.project
  | from json
  | update version $version
  | to json
