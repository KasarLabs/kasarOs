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
	Last:  0.00,
	Min:   0.00,
	Max:   0.00,
	Avg:   0.00,
	Count: 0,
}

func getBlockData() types.L1Block {
	client, err := ethclient.Dial(config.User.RpcKey)
	if err != nil {
		log.Fatal(err)
	}
	data, err := client.BlockByNumber(context.Background(), nil)
	if err != nil {
		log.Fatal(err)
	}

	block := types.L1Block{
		ParentHash:  data.ParentHash().Hex(),
		UncleHash:   data.UncleHash().Hex(),
		Coinbase:    data.Coinbase().Hex(),
		Root:        data.Root().Hex(),
		TxHash:      data.TxHash().Hex(),
		ReceiptHash: data.ReceiptHash().Hex(),
		Difficulty:  data.Difficulty().Int64(),
		Number:      data.Number().Int64(),
		GasLimit:    data.GasLimit(),
		GasUsed:     data.GasUsed(),
		Time:        data.Time(),
		Extra:       data.Extra(),
		MixDigest:   data.MixDigest().Hex(),
		BaseFee:     data.BaseFee().Int64(),
	}

	return block
}

func getSyncTime(block types.L1Block, local types.Local) types.SyncTime {
	syncTime.Count++
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

var (
	isFirstCall = true
	num         int64
)

func ScannerL1(baseUrl string, nodeId uint) types.L1 {

	block := getBlockData()

	if isFirstCall {
		num = block.Number
		isFirstCall = false
	}

	if block.Number > num {
		num = block.Number
		// push block to DB

		// Update the local timestamp
		local.Prev_timestamp = local.Timestamp
		local.Timestamp = time.Now()

		// Calculate the sync time
		syncTime := getSyncTime(block, local)
		if syncTime.Last.Seconds() > 9999999 {
			return types.L1{Block: block, SyncTime: syncTime}
		}

		data := L1{
			NodeID:   nodeId,
			Block:    uint(block.Number),
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
