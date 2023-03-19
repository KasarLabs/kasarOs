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
	"math"
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

type Block struct {
	hash				string
	number				int64
	new_root			string
    parent_hash			string
    sequencer_address	string
    status				string
    timestamp			int64
    transactions		[]string
	local 				Local
}

type Local struct {
	number			int64
	timestamp		int64
	prev_timestamp	int64
}

type SyncTime struct {
	last	float64
	min		float64
	max 	float64
	avg		float64
	count	int64
}	

var syncTime = SyncTime {
	last: 0.00,
	min: 0.00,
	max: 0.00,
	avg: 0.00,
	count: 0,
}

var local = Local {
	number: 0,
	timestamp: 0,
	prev_timestamp: 0,
}

func getSyncTime(block Block, local Local) {
	syncTime.count += 1;
	syncTime.last = float64(local.timestamp - local.prev_timestamp);
	if (syncTime.count > 3) {
		// Set min max syncTime
		if (syncTime.last > syncTime.max) {
			syncTime.max = syncTime.last
		} else if (syncTime.last < syncTime.min) {
			syncTime.min = syncTime.last
		}
		// Set avg syncTime
		syncTime.avg = math.Round(float64((syncTime.avg + syncTime.last) / 2) * 100) / 100
		// Push to DB
		fmt.Println("Pushing to DB", syncTime)

	} else {
		syncTime.min = syncTime.last
	}
}

func getBlockData(blockNumber int64) (block Block, err error) {
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
	block = Block{
		hash:              response.Result.BlockHash,
		number:            response.Result.BlockNumber,
		new_root:          response.Result.NewRoot,
		parent_hash:       response.Result.ParentHash,
		sequencer_address: response.Result.SequencerAddress,
		status:            response.Result.Status,
		timestamp:         response.Result.Timestamp,
		transactions:      response.Result.Transactions,
	}
	return block, nil
}

func ScannerL2() {
	absPath, err := filepath.Abs(logsFile)
	if err != nil {
		fmt.Println(err)
	}
	if syncTime.last == 0 {
		syncTime.last = float64(time.Now().Unix())
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
				if (number > local.number) {
					block, err := getBlockData(number)
					if err != nil {
						panic(err)
					}
					if (syncTime.count <= 0) {
						block.local.timestamp = 0
					}
					local.number = number
					local.prev_timestamp = local.timestamp
					local.timestamp, _ = utils.ExtractTimestamp(line)
					getSyncTime(block, local)
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
