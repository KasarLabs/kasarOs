package main

import (
	"myOsiris/network/l2/scanner"
)


const (
	logsFile           = "client/logs.txt"
	dbConnectionString = "root:tokenApi!@tcp(localhost:3306)/juno"
)

type Block struct {
	number    int64
	syncTime  int64
	hash      string
}

func main() {
	scanner.Scanner()
}