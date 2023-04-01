package main

import (

	"myOsiris/network/scannerL1"
	"myOsiris/network/scannerL2"
	"fmt"
	// "sync"
	// "time"
	"myOsiris/network/config"
    _ "github.com/lib/pq" // Import PostgreSQL driver
	"myOsiris/system"
	// "myOsiris/db"
	"os/exec"
)

var nodeConfig = config.User

func main() {
	// Check if the config is structured properly
	err := config.CheckConfig("config.json")
	if err != nil {
		fmt.Println(err)
	}
	scriptPath := "./network/utils/banner.sh"

	cmd := exec.Command("bash", scriptPath)

	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Printf("Error running script: %v\n", err)
		return
	}

	fmt.Print(string(output))

	// var mu sync.Mutex

	// Starting trackers
	fmt.Println("Starting tracker...")
	go func() {
		for {
			scannerL2.ScannerL2()
		}
	}()

	go func() {
		// Print an initial line to separate process L1 output
		fmt.Println()
		for {
			scannerL1.ScannerL1()
		}
	}()
	go func() {
		for {
			system.ScannerSystem()
		}
	}()
	select {}
}