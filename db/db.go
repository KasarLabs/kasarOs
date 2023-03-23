package db

import (
	"log"
	"fmt"
    "net/http"
	"encoding/json"
	"myOsiris/network/config"
	"myOsiris/types"
)

const Url = "http://localhost:8080/"
var nodeConfig config.Config = config.User

func NodeExist(nodeID string) (bool) {
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
        fmt.Printf("Node %s exists\n", nodeID)
		return(true)
	}
    fmt.Printf("Node %s does not exist\n", nodeID)
	return(false)
}

func CreateNode(nodeID string) (bool) {
    if (NodeExist(nodeID)) {
        fmt.Println("Node already exist")
        return false
    }
	resp, err := http.Get(Url + "createNode?nodeID=" + nodeID)
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

func GetNode(nodeID string) (types.Node, error) {
    if (!NodeExist(nodeID)) {
        fmt.Println("Node doesn't exist")
        return types.Node{}, fmt.Errorf("Node with ID %s not found", nodeID)
    }
	resp, err := http.Get(Url + "getNode?nodeID=" + nodeID)
	if err != nil {
		return types.Node{}, fmt.Errorf("Error making HTTP request: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		return types.Node{}, fmt.Errorf("Received non-OK status code: %d", resp.StatusCode)
	}

    var node types.Node
    if err := json.NewDecoder(resp.Body).Decode(&node); err != nil {
        return types.Node{}, fmt.Errorf("Error decoding response body: %v", err)
    }

    fmt.Printf("Node %s retrieved successfully\n", nodeID)
    return node, nil
}

