package main

import (

	"myOsiris/network/scannerL1"
	"myOsiris/network/scannerL2"
)


const (
	logsFile           = "network/logs.txt"
	dbConnectionString = "root:tokenApi!@tcp(localhost:3306)/juno"
)

func main() {
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
	select {}
}