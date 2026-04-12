open $env.languages_toml
  | get grammar
  | where source? != null
  | par-each --threads 16 {|grammar|
    let name = $grammar.name
    let repo = $grammar.source.git
    let rev = $grammar.source.rev
    let subpath = ($grammar.source.subpath? | default "")

    print $"Building grammar: ($name)"

    let clone_dir = mktemp -d

    try {
      ^git -c advice.detachedHead=false clone --depth 1 --revision $rev $repo $clone_dir
    } catch {
      print $"Skipping ($name): clone failed"
      rm -rf $clone_dir
      return
    }

    mut srcdir = $clone_dir
    if $subpath != "" {
      $srcdir = $"($srcdir)/($subpath)"
    }

    let out = $"($env.BRIOCHE_OUTPUT)/($name).so"

    if ($"($srcdir)/src/scanner.cc" | path exists) {
      let obj = $"($clone_dir)/scanner.o"
      ^g++ -fPIC -fno-exceptions -I $"($srcdir)/src" -o $obj -std=c++14 -c $"($srcdir)/src/scanner.cc"
      ^gcc -fPIC -fno-exceptions -I $"($srcdir)/src" -shared -o $out $obj -xc -std=c11 $"($srcdir)/src/parser.c"
    } else if ($"($srcdir)/src/scanner.c" | path exists) {
      ^gcc -fPIC -fno-exceptions -I $"($srcdir)/src" -shared -o $out -xc -std=c11 $"($srcdir)/src/scanner.c" $"($srcdir)/src/parser.c"
    } else {
      ^gcc -fPIC -fno-exceptions -I $"($srcdir)/src" -shared -o $out -xc -std=c11 $"($srcdir)/src/parser.c"
    }

    rm -rf $clone_dir
  }
