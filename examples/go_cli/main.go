package main

import (
	"flag"
	"os"
	"time"

	"github.com/schollz/progressbar/v3"
)

func main() {
	wait := flag.Duration("wait", time.Second, "duration to wait")
	// help := flag.Bool("help", false, "show usage")
	flag.Parse()

	// if help != nil && *help {
	// 	flag.Usage()
	// 	return
	// }

	if wait == nil {
		flag.Usage()
		os.Exit(1)
	}

	bar := progressbar.NewOptions64(wait.Milliseconds())
	start := time.Now()

	for {
		elapsed := time.Since(start)
		if elapsed > *wait {
			break
		}

		bar.Set64(elapsed.Milliseconds())
		time.Sleep(time.Millisecond * 100)
	}

	bar.Finish()
	println()
}
