let version = http get $'https://registry.npmjs.org/($env.packageName)/latest'
  | get version

let parsedVersion = $version
  | parse --regex $env.matchVersion
if ($parsedVersion | length) == 0 {
  error make { msg: $'Latest release ($version) did not match regex ($env.matchVersion)' }
}

let version = $parsedVersion.0.version?
if $version == null {
  error make { msg: $'Regex ($env.matchVersion) did not include version when matching latest release ($version)' }
}

$env.project
  | from json
  | update version $version
  | to json
