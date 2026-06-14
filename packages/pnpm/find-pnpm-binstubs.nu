ls .bin/**/*
  | where type == file
  | each {|bin|
    let firstLine = open $bin.name --raw
      | lines
      | first

    { name: $bin.name, firstLine: $firstLine }
  }
  | where ($it.firstLine | str contains "bin/sh")
  | select name
  | to json
  | save $env.BRIOCHE_OUTPUT
