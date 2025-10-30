ls .bin/**/*
  | where type == file
  | each {|bin|
    let firstLine = open $bin.name --raw
      | split row -r '\n'
      | first

    { name: $bin.name, firstLine: $firstLine }
  }
  | where {|bin| $bin.firstLine | str contains "bin/sh"}
  | select name
  | to json
  | save $env.BRIOCHE_OUTPUT
