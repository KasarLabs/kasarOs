package scannerL2

import (
	"bufio"
	"fmt"
	"myOsiris/network/utils"
	"myOsiris/types"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	// "math"
	"bytes"
	"encoding/json"
	"net/http"

	_ "github.com/go-sql-driver/mysql"
)

type L2 struct {
	NodeID   uint
	Block    uint
	SyncTime float64
}

const (
	logsFile           = "./network/logs.txt"
	dbConnectionString = "root:tokenApi!@tcp(localhost:3306)/juno"
)

var local = types.Local{
	Number:         0,
	Timestamp:      time.Time{},
	Prev_timestamp: time.Time{},
}

var syncTime = types.SyncTime{
	Last: 0.00,
}

func getSyncTime(local types.Local) types.SyncTime {
	syncTime.Count += 1
	syncTime.Last = local.Timestamp.Sub(local.Prev_timestamp)
	return syncTime
}

func ScannerL2(baseUrl string, nodeId uint) types.L2 {
	absPath, err := filepath.Abs(logsFile)
	if err != nil {
		fmt.Println(err)
	}
	if syncTime.Last == 0 {
		syncTime.Last = time.Duration(0 * time.Millisecond)
	}
	// Get initial size of the file
	fileinfo, err := os.Stat(absPath)
	if err != nil {
		panic(err)
	}
	size := fileinfo.Size()
	// Loop continuously to read new lines from the file
	for {
		file, err := os.Open(absPath)
		if err != nil {
			panic(err)
		}
		// Seek to the last byte offset read
		_, err = file.Seek(size, 0)
		if err != nil {
			panic(err)
		}
		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			line := strings.ReplaceAll(utils.RemoveBraces(scanner.Text()), " ", "\t")
			if len(line) > 0 {
				number, _ := strconv.ParseInt(utils.ExtractNumber(line), 10, 64)
				if number > local.Number {
					local.Number = number
					local.Prev_timestamp = local.Timestamp
					local.Timestamp, _ = utils.ExtractTimestamp(line)
					syncTime := getSyncTime(local)
					if syncTime.Last.Seconds() > 9999999 {
						continue
					}

					/*rows, err := db.Query("INSERT INTO l2 (node_id, block_id, sync_time) VALUES ($1, $2, $3)", nodeId, l2.Block.Number, l2.SyncTime.Avg.Seconds())
					if err != nil {
						log.Fatal(err)
					}
					defer rows.Close()*/
					//fmt.Printf("\033[s\033[2K\rL2 - Block number %d with id %s synced in %.2f secs - avg sync time %.2f \033[u", l2.Block.Number, utils.FormatHash(l2.Block.Hash), l2.SyncTime.Last.Seconds(), l2.SyncTime.Avg.Seconds())
					data := L2{
						NodeID:   nodeId,
						Block:    uint(local.Number),
						SyncTime: syncTime.Last.Seconds(),
					}
					jsonData, err := json.Marshal(data)
					if err != nil {
						return types.L2{}
					}
					request, err := http.NewRequest("POST", baseUrl, bytes.NewBuffer(jsonData))
					if err != nil {
						return types.L2{}
					}
					request.Header.Set("Content-Type", "application/json")

					client := &http.Client{}
					response, err := client.Do(request)
					if err != nil {

						return types.L2{}
					}
					response.Body.Close()
					continue
				}
			}
			// Update the size variable to the current byte offset
			size, err = file.Seek(0, os.SEEK_CUR)
			if err != nil {
				panic(err)
			}
		}
		if err := scanner.Err(); err != nil {
			fmt.Println("Error scanning file:", err)
		}
		file.Close()
		time.Sleep(1 * time.Second) // wait for 1 second before checking the file again
	}
}
