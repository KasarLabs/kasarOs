package scannerL1

import (
	"bytes"
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"myOsiris/network/config"
	"myOsiris/types"

	"github.com/ethereum/go-ethereum/ethclient"
)

type L1 struct {
	NodeID   uint
	Block    uint
	SyncTime float64
}

var local = types.Local{
	Number:         0,
	Timestamp:      time.Time{},
	Prev_timestamp: time.Time{},
}

var syncTime = types.SyncTime{
	Last: 0.00,
}

func getBlockNumber() int64 {
	client, err := ethclient.Dial(config.User.RpcKey)
	if err != nil {
		log.Fatal(err)
	}
	data, err := client.BlockByNumber(context.Background(), nil)
	if err != nil {
		log.Fatal(err)
	}

	return data.Number().Int64()
}

func getSyncTime(local types.Local) types.SyncTime {
	syncTime.Count++
	syncTime.Last = local.Timestamp.Sub(local.Prev_timestamp)

	return syncTime
}

var (
	isFirstCall = true
	num         int64
)

func ScannerL1(baseUrl string, nodeId uint) types.L1 {

	blockNumber := getBlockNumber()

	if isFirstCall {
		num = blockNumber
		isFirstCall = false
	}

	if blockNumber > num {
		num = blockNumber

		local.Prev_timestamp = local.Timestamp
		local.Timestamp = time.Now()

		syncTime := getSyncTime(local)
		if syncTime.Last.Seconds() > 9999999 {
			return types.L1{}
		}

		data := L1{
			NodeID:   nodeId,
			Block:    uint(num),
			SyncTime: syncTime.Last.Seconds(),
		}
		jsonData, err := json.Marshal(data)
		if err != nil {
			return types.L1{}
		}
		request, err := http.NewRequest("POST", baseUrl, bytes.NewBuffer(jsonData))
		if err != nil {

			return types.L1{}
		}
		request.Header.Set("Content-Type", "application/json")

		client := &http.Client{}
		response, err := client.Do(request)
		if err != nil {

			return types.L1{}
		}
		response.Body.Close()
	}

	return types.L1{}
}
