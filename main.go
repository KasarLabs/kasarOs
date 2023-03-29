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
		for {
			mu.Lock()
			scannerL2.ScannerL2()
			mu.Unlock()
			time.Sleep(time.Millisecond * 500)
		}
	}()
	go func() {
		for {
			mu.Lock()
			scannerL1.ScannerL1()
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