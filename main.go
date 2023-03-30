package main

import (

	"myOsiris/network/scannerL1"
	"myOsiris/network/scannerL2"
	"fmt"
	"sync"
	"time"
	"myOsiris/network/config"
    _ "github.com/lib/pq" // Import PostgreSQL driver
	// "myOsiris/system"
	// "myOsiris/db"
)

var nodeConfig = config.User

func main() {
	// Check if the config is structured properly
	err := config.CheckConfig("config.json")
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println("Starting tracker...")

	var mu sync.Mutex

	// Starting trackers
	go func() {
		i := 1
		for {
			mu.Lock()
			l2Block, l2Time := scannerL2.ScannerL2()
			fmt.Printf("\033[s\033[2K\rL2 - %v, %v\033[u", l2Block, l2Time)
			i++
			mu.Unlock()
			time.Sleep(time.Millisecond * 500)
		}
	}()

	go func() {
		// Print an initial line to separate process L1 output
		fmt.Println()
		for {
			mu.Lock()
			l1 := scannerL1.ScannerL1()
			fmt.Printf("\033[s\033[1A\033[2K\rL1 - last block sync %d\033[u", l1.Number)
			mu.Unlock()
			time.Sleep(time.Millisecond * 500)
		}
	}()
	// go func() {
	// 	for {
	// 		system.ScannerSystem()
	// 	}
	// }()
	select {}
}