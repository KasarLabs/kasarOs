package main

import (

	"myOsiris/network/scannerL1"
	"myOsiris/network/scannerL2"
	"fmt"
	"myOsiris/network/config"
    _ "github.com/lib/pq" // Import PostgreSQL driver
	// "myOsiris/system"
	// "myOsiris/db"
)

var nodeConfig = config.User

func main() {
	err := config.CheckConfig("config.json")
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println("Starting tracker...")
		// db.CreateNode(nodeConfig.OsirisKey)
	// db.CreateNode(nodeConfig.OsirisKey)
	// fmt.Println(db.GetNode(nodeConfig.OsirisKey))
	// db.NodeExist(nodeConfig.OsirisKey)
	go func() {
		for {
			scannerL2.ScannerL2()
		}
	}()

	go func() {
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