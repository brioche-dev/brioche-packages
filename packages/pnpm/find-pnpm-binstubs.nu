cd $env.recipe

ls .bin/**/*
  | where type == file
  | each {|bin|
    let contents = open $bin.name --raw
    let firstLine = $contents
      | split row -r '\n'
      | first
    { name: $bin.name, firstLine: $firstLine }
  }
  | where {|bin| $bin.firstLine | str contains "bin/sh"}
  | select name
  | to json
  | save $env.BRIOCHE_OUTPUT
