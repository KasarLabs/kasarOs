package scannerL2

import (
	"bufio"
	"fmt"
	"os"
	"time"
	"strings"
	"strconv"
	"path/filepath"
	"myOsiris/network/utils"
	"myOsiris/types"
	// "math"
	"bytes"
	"encoding/json"
	"io/ioutil"
	"net/http"

	_ "github.com/go-sql-driver/mysql"
)


const (
	logsFile           = "./network/logs.txt"
	dbConnectionString = "root:tokenApi!@tcp(localhost:3306)/juno"
)

var local = types.Local{
	Number:         0,
	Timestamp:      time.Time{},
	Prev_timestamp: time.Time{},
}

var syncTime = types.SyncTime {
	Last: 0.00,
	Min: 0.00,
	Max: 0.00,
	Avg: 0.00,
	Count: 0,
}

func getSyncTime(block types.L2Block, local types.Local) types.SyncTime {
	syncTime.Count += 1
	syncTime.Last = local.Timestamp.Sub(local.Prev_timestamp)
	if syncTime.Count > 3 {
		if syncTime.Last > syncTime.Max {
			syncTime.Max = syncTime.Last
		} else if syncTime.Last < syncTime.Min {
			syncTime.Min = syncTime.Last
		}
		syncTime.Avg = (syncTime.Avg + syncTime.Last) / 2
		return syncTime

	} else {
		syncTime.Min = syncTime.Last
	}
	return syncTime
}

func getBlockData(blockNumber int64) (block types.L2Block, err error) {
	url := "https://starknet-mainnet.infura.io/v3/bfd7c1b53bea4e1ebe1bd41aa8f52aaf"
	payload := []byte(fmt.Sprintf(`{"jsonrpc": "2.0", "method": "starknet_getBlockWithTxHashes", "params": {"block_id": {"block_number": %d}}, "id": 0}`, blockNumber))
	resp, err := http.Post(url, "application/json", bytes.NewBuffer(payload))
	if err != nil {
		return block, err
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return block, err
	}
	var response struct {
		Result struct {
			BlockHash         string   `json:"block_hash"`
			BlockNumber       int64    `json:"block_number"`
			NewRoot           string   `json:"new_root"`
			ParentHash        string   `json:"parent_hash"`
			SequencerAddress  string   `json:"sequencer_address"`
			Status            string   `json:"status"`
			Timestamp         int64    `json:"timestamp"`
			Transactions      []string `json:"transactions"`
		} `json:"result"`
	}
	err = json.Unmarshal(body, &response)
	if err != nil {
		return block, err
	}
	block = types.L2Block{
		Hash:              response.Result.BlockHash,
		Number:            response.Result.BlockNumber,
		New_root:          response.Result.NewRoot,
		Parent_hash:       response.Result.ParentHash,
		Sequencer_address: response.Result.SequencerAddress,
		Status:            response.Result.Status,
		Timestamp:         response.Result.Timestamp,
		Transactions:      response.Result.Transactions,
	}
	return block, nil
}

func ScannerL2() (block types.L2Block, syncTime types.SyncTime) {
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
				if (number > local.Number) {
					block, err := getBlockData(number)
					if err != nil {
						panic(err)
					}
					if syncTime.Count <= 0 {
						block.Local.Timestamp = time.Time{}
					}
					local.Number = number
					local.Prev_timestamp = local.Timestamp
					local.Timestamp, _ = utils.ExtractTimestamp(line)
					syncTime := getSyncTime(block, local)
					if (syncTime.Last.Seconds() > 9999999) {
						continue
					}
					fmt.Printf("\033[s\033[2K\rL2 - Block number %d with id %s synced in %.2f secs - avg sync time %.2f \033[u", block.Number, utils.FormatHash(block.Hash), syncTime.Last.Seconds(), syncTime.Avg.Seconds())
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
