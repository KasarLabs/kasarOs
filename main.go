package main

import (
	"myOsiris/network/l2/scanner"
)


const (
	logsFile           = "network/l2/logs.txt"
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