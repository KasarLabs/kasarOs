package main

import (

	"myOsiris/network/l1/scannerL1"
	"myOsiris/network/l2/scannerL2"
)


const (
	logsFile           = "network/l2/logs.txt"
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