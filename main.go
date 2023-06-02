package main

import (
	"fmt"
	"strconv"

	"myOsiris/network/config"
	"myOsiris/network/scannerL1"
	"myOsiris/network/scannerL2"
	"myOsiris/system"

	"github.com/google/uuid"
	_ "github.com/lib/pq"
	/*"myOsiris/network/scannerL1"
	  "myOsiris/network/scannerL2"
	  "myOsiris/system"*/)

var nodeConfig = config.User

func main() {
	// Check if the config is structured properly

	baseUrl := "http://179.61.246.59:8080/"

	err := config.CheckConfig("config.json")
	if err != nil {
		fmt.Println(err)
	}
	nodeId, err := strconv.Atoi(nodeConfig.NodeID)
	if err != nil {
		fmt.Println("Error during Atoi :", err)
		return
	}
	providerId, err := uuid.Parse(nodeConfig.ProviderID)
	if err != nil {
		fmt.Println("Error during ProviderID :", err)
		return
	}

	// Start myOsiris tracker

	// Reset
	// resetCmd := exec.Command("reset & sleep 1")
	// _, err = resetCmd.Output()
	// if err != nil {
	//     fmt.Printf("Error running reset command: %v\n", err)
	//     return
	// }

	// scriptPath := "./network/utils/banner.sh"
	// cmd := exec.Command("bash", scriptPath)

	// output, err := cmd.CombinedOutput()
	// if err != nil {
	//     fmt.Printf("Error running script: %v\n", err)
	//     return
	// }

	// fmt.Print(string(output))

	// Starting trackers
	// fmt.Println("Starting tracker...")

	go func() {
		for {
			scannerL2.ScannerL2(baseUrl+"node/L2/update?provider_id"+providerId.String(), uint(nodeId))
		}
	}()

	go func() {
		// Print an initial line to separate process L1 output
		// fmt.Println()
		for {
			scannerL1.ScannerL1(baseUrl+"node/L1/update?provider_id"+providerId.String(), uint(nodeId))
		}
	}()

	go func() {
		for {
			system.ScannerSystem(baseUrl, uint(nodeId), providerId)
		}
	}()

	select {}
}
