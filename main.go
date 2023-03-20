package main

import (

	// "myOsiris/network/scannerL1"
	// "myOsiris/network/scannerL2"
    _ "github.com/lib/pq" // Import PostgreSQL driver
	// "myOsiris/system"
	"log"
	"fmt"
    "net/http"
	"encoding/json"
	"myOsiris/network/config"
)

func main() {
	nodeConfig := config.User

    url := fmt.Sprintf("http://localhost:8080/nodeExists?nodeID=%s", nodeConfig.OsirisKey)
    resp, err := http.Get(url)
    if err != nil {
        log.Fatalf("Error making HTTP request: %v", err)
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        log.Fatalf("Received non-OK status code: %d", resp.StatusCode)
    }

    var response struct {
        Exists bool `json:"exists"`
    }
    err = json.NewDecoder(resp.Body).Decode(&response)
    if err != nil {
        log.Fatalf("Error decoding JSON response: %v", err)
    }

    if response.Exists {
        fmt.Printf("Node %s exists\n", nodeConfig.OsirisKey)
    } else {
        fmt.Printf("Node %s does not exist\n", nodeConfig.OsirisKey)
    }
	// go func() {
	// 	for {
	// 		scannerL2.ScannerL2()
	// 	}
	// }()

	// go func() {
	// 	for {
	// 		scannerL1.ScannerL1()
	// 	}	
	// }()
	// go func() {
	// 	for {
	// 		system.ScannerSystem()
	// 	}
	// }()
	// select {}
}