package main

import (

	// "myOsiris/network/scannerL1"
	// "myOsiris/network/scannerL2"
    _ "github.com/lib/pq" // Import PostgreSQL driver
	// "myOsiris/system"
	"myOsiris/db"
)

func main() {
    db.CreateNode()
	db.UserExist("10")
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