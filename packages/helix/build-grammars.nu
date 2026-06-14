def archive-url [repo: string, rev: string]: nothing -> string {
  let parts = $repo
    | url parse
  let path = $parts.path
    | str trim --left --char '/'
    | str trim --right --char '/'
    | str replace '.git' ''
  let host = $parts.host

  match $host {
    "gitlab.com" => {
        let repo_name = $path
          | split row '/'
          | get 1

        $"https://($host)/($path)/-/archive/($rev)/($repo_name)-($rev).tar.gz"
    },
    _ => $"https://($host)/($path)/archive/($rev).tar.gz",
  }
}

open $env.languages_toml
  | get grammar
  | where source? != null
  # Number of threads is deliberately set to 2 to avoid rate limiting
  | par-each --threads 2 {|grammar|
    let name = $grammar.name
    let repo = $grammar.source.git
    let rev = $grammar.source.rev
    let subpath = ($grammar.source.subpath? | default "")

    let src_dir = mktemp -d
    let url = archive-url $repo $rev

    print $"Downloading grammar '($name)' \(($url)\)"

    let archive = $"($src_dir)/archive.tar.gz"

    try {
      ^curl -sfL -o $archive $url
    } catch {
      print $"Skipping '($name)': download failed"
      rm -rf $src_dir
      return
    }

    ^tar xzf $archive -C $src_dir --strip-components=1

    { name: $name, src_dir: $src_dir, subpath: $subpath }
  }
  | par-each --threads 16 {|source|
    let name = $source.name
    let src_dir = $source.src_dir

    mut srcdir = $src_dir
    if $source.subpath != "" {
      $srcdir = $"($srcdir)/($source.subpath)"
    }

    print $"Building grammar '($name)'"

    let out = $"($env.BRIOCHE_OUTPUT)/($name).so"

    if ($"($srcdir)/src/scanner.cc" | path exists) {
      let obj = $"($src_dir)/scanner.o"
      ^g++ -fPIC -fno-exceptions -I $"($srcdir)/src" -o $obj -std=c++14 -c $"($srcdir)/src/scanner.cc"
      ^gcc -fPIC -fno-exceptions -I $"($srcdir)/src" -shared -o $out $obj -xc -std=c11 $"($srcdir)/src/parser.c"
    } else if ($"($srcdir)/src/scanner.c" | path exists) {
      ^gcc -fPIC -fno-exceptions -I $"($srcdir)/src" -shared -o $out -xc -std=c11 $"($srcdir)/src/scanner.c" $"($srcdir)/src/parser.c"
    } else {
      ^gcc -fPIC -fno-exceptions -I $"($srcdir)/src" -shared -o $out -xc -std=c11 $"($srcdir)/src/parser.c"
    }

    rm -rf $src_dir
  }
  | ignore
