package scanner

import (
	"bufio"
	"fmt"
	"os"
	"time"
	"strings"
	"strconv"
	"path/filepath"
	"myOsiris/network/l2/utils"

	_ "github.com/go-sql-driver/mysql"
)


const (
	logsFile           = "./client/logs.txt"
	dbConnectionString = "root:tokenApi!@tcp(localhost:3306)/juno"
)

type Block struct {
	number    int64
	timestamp  int64
	last_ts	int64
}

var block = Block {
	number: 0,
	timestamp: 0,
	last_ts: 0,
}

type SyncTime struct {
	last	int64
	min		int64
	max 	int64
	avg		int64
	count	int64
}

var syncTime = SyncTime {
	last: 0,
	min: 0,
	max: 0,
	avg: 0,
	count: 0,
}

func setSyncTime(block Block) {
	syncTime.count += 1;
	syncTime.last = block.timestamp - block.last_ts;
	if (syncTime.count > 1) {
		// Set min max syncTime
		if (syncTime.last > syncTime.max) {
			syncTime.max = syncTime.last
		} else if (syncTime.last < syncTime.min) {
			syncTime.min = syncTime.last
		}
		// Set avg syncTime
		syncTime.avg = (syncTime.avg + syncTime.last) / 2
	} else {
		syncTime.min = syncTime.last
	}
	fmt.Println(syncTime)
}

func Scanner() {
	absPath, err := filepath.Abs(logsFile)
	if err != nil {
		fmt.Println(err)
	}
	if (syncTime.last == 0) {
		syncTime.last = time.Now().Unix()
	}
	// Loop continuously to read new lines from the file
	for {
		file, err := os.Open(absPath)
		if err != nil {
			panic(err)
		}
		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			line := scanner.Text()
			if len(line) > 0 {
				liner := strings.ReplaceAll(utils.RemoveBraces(line), " ", "\t")
				number, _ := strconv.ParseInt(utils.ExtractNumber(liner), 10, 64)
				if (number > block.number) {
					lineParsed := strings.Split(liner, "\t")
					time, err := utils.ParseTimestamp(lineParsed[0] + " " + lineParsed[1] + " " + lineParsed[2])
					if err != nil {
						fmt.Println(err)
					}
					timestamp := time.Unix()
					block.number = number
					block.last_ts = block.timestamp
					block.timestamp = timestamp
					setSyncTime(block)
				}
			}
		}
		if err := scanner.Err(); err != nil {
			fmt.Println("Error scanning file:", err)
		}
		file.Close()
		time.Sleep(1 * time.Second) // wait for 1 second before checking the file again
	}
}