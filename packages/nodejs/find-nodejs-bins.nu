cd $env.recipe

ls bin/**/*
  | where type == symlink
  | each {|bin|
    let target = $bin.name
      | path expand
      | path relative-to (pwd --physical)

    let contents = open $bin.name --raw
    let firstLine = $contents
      | split row -r '\n'
      | first
    { name: $bin.name, target: $target, firstLine: $firstLine }
  }
  | where {|bin| $bin.firstLine | str contains "node"}
  | select name target
  | to json
  | save $env.BRIOCHE_OUTPUT
