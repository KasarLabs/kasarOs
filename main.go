package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"

	"myOsiris/network/config"
	"myOsiris/network/scannerL1"
	"myOsiris/network/scannerL2"
	"myOsiris/system"
	/*"myOsiris/network/scannerL1"
	  "myOsiris/network/scannerL2"
	  "myOsiris/system"*/)

var nodeConfig = config.User

func main() {
	// Check if the config is structured properly
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	dbUsername := os.Getenv("DB_USERNAME")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbHost := os.Getenv("DB_HOST")
	dbName := os.Getenv("DB_NAME")

	err = config.CheckConfig("config.json")
	if err != nil {
		fmt.Println(err)
	}
	nodeId, err := strconv.Atoi(nodeConfig.NodeID)
	if err != nil {
		fmt.Println("Error during Atoi :", err)
		return
	}

	db, err := sql.Open("postgres", "postgres://"+dbUsername+":"+dbPassword+"@"+dbHost+"/"+dbName+"?sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		log.Fatal(err)
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
			scannerL2.ScannerL2(db, uint(nodeId))
		}
	}()

	go func() {
		// Print an initial line to separate process L1 output
		// fmt.Println()
		for {
			scannerL1.ScannerL1(db, uint(nodeId))
		}
	}()

	go func() {
		for {
			system.ScannerSystem(db, uint(nodeId))
		}
	}()

	select {}
}
