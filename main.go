package main

import (

	"myOsiris/network/scannerL1"
	"myOsiris/network/scannerL2"
	"fmt"
	// "sync"
	// "time"
	"log"
	"myOsiris/network/config"
    _ "github.com/lib/pq" // Import PostgreSQL driver
	// "myOsiris/system"
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
    
	getLogs := fmt.Sprintf("sudo docker logs -f %s &>> ./network/logs.txt &", config.User.Client)

	cmd1 := exec.Command("/bin/bash", "-c", getLogs)
	_, err1 := cmd1.CombinedOutput()
	if err1 != nil {
		log.Fatalf("Failed to get combined output: %v", err1)
	}

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
	// go func() {
	// 	for {
	// 		system.ScannerSystem()
	// 	}
	// }()
	select {}
}