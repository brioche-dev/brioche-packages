# Recursive function to get the latest module name
# In other words, it finds the latest major version of a module
def get-latest-module-name [
  moduleName: string # The module name to check
]: nothing -> string {
  let parsedModuleName = $moduleName
    | parse --regex "^(?<name>.+?)(?:\/v(?<version>[0-9]+))?$"
    | into record
  if ($parsedModuleName | is-empty) {
      return $moduleName
  }

  let majorVersion = if ($parsedModuleName.version | is-not-empty) {
    $parsedModuleName.version
      | into int
  } else {
    1
  }

  let nextLatestModuleName = $'($parsedModuleName.name)/v($majorVersion + 1)'

  http get --allow-errors --pool $'https://proxy.golang.org/($nextLatestModuleName)/@latest'
    # Check the response status
    | metadata access {|meta|
      match $meta.http_response.status {
        200 => {
          # If the version is found, try the next one
          get-latest-module-name $nextLatestModuleName
        }
        _ => {
          # On error, return the current module name
          $moduleName
        }
      }
    }
}

let moduleName = get-latest-module-name $env.moduleName

# Retrieve the most recent releases from Go proxy registry
let releases = http get --pool $'https://proxy.golang.org/($moduleName)/@v/list'
  | lines
  # Extract the version(s)
  | each {|release|
    $release
      | parse --regex $env.matchVersion
      | into record
  }
  | where (($it | get -o version) | is-not-empty)
  | sort-by --natural version

if ($releases | is-empty) {
  error make { msg: $'No version does match regex ($env.matchVersion)' }
}

# Get the latest release
let latestReleaseInfo = $releases
  | last

# Get the version
let version = $latestReleaseInfo.version

# Get project metadata, and update it
mut project = $env.project
  | from json

$project = $project
  | update version $version
  | update extra.moduleName $moduleName

# Return back the project metadata encoded as JSON
$project
  | to json
