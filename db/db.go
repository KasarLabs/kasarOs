package db

import (
	"log"
	"fmt"
    "net/http"
	"encoding/json"
	"myOsiris/network/config"
)

const Url = "http://localhost:8080/"
var nodeConfig config.Config = config.User

func NodeExist() (bool) {
	resp, err := http.Get(Url + "nodeExists?nodeID=" + nodeConfig.OsirisKey)
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
		return(true)
	}
    fmt.Printf("Node %s does not exist\n", nodeConfig.OsirisKey)
	return(false)
}

func CreateNode() (bool) {
    if (NodeExist()) {
        fmt.Println("Node already exist")
        return false
    }
	resp, err := http.Get(Url + "createNode?nodeID=" + nodeConfig.OsirisKey)
	if err != nil {
		log.Fatalf("Error making HTTP request: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		log.Fatalf("Received non-OK status code: %d", resp.StatusCode)
	}

	fmt.Printf("Node %s created successfully\n", nodeConfig.OsirisKey)
	return(true)
}

