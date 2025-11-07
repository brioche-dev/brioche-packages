ls bin/**/*
  | where type == symlink
  | each {|bin|
    let target = $bin.name
      | path expand
      | path relative-to (pwd --physical)

    let firstLine = open $bin.name --raw
      | split row -r '\n'
      | first

    { name: $bin.name, target: $target, firstLine: $firstLine }
  }
  | where ($it.firstLine | str contains "node")
  | select name target
  | to json
  | save $env.BRIOCHE_OUTPUT
