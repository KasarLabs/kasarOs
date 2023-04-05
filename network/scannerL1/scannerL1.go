package scannerL1

import (
	"context"
	"log"
	"math/big"
	"fmt"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
	"myOsiris/network/utils"
	"myOsiris/network/config"
	"time"
)

type L1 struct {
	Block    Block
	SyncTime SyncTime
}

type Block struct {
	ParentHash    common.Hash    `json:"parentHash"       gencodec:"required"`
	UncleHash     common.Hash    `json:"sha3Uncles"       gencodec:"required"`
	Coinbase      common.Address `json:"miner"`
	Root          common.Hash    `json:"stateRoot"        gencodec:"required"`
	TxHash        common.Hash    `json:"transactionsRoot" gencodec:"required"`
	ReceiptHash   common.Hash    `json:"receiptsRoot"     gencodec:"required"`
	Difficulty    *big.Int       `json:"difficulty"       gencodec:"required"`
	Number        *big.Int       `json:"number"           gencodec:"required"`
	GasLimit      uint64         `json:"gasLimit"         gencodec:"required"`
	GasUsed       uint64         `json:"gasUsed"          gencodec:"required"`
	Time          uint64         `json:"timestamp"        gencodec:"required"`
	Extra         []byte         `json:"extraData"        gencodec:"required"`
	MixDigest     common.Hash    `json:"mixHash"`
	BaseFee       *big.Int       `json:"baseFeePerGas" rlp:"optional"`
}

type Local struct {
	number          int64
	timestamp       time.Time
	prev_timestamp  time.Time
}

var local = Local {
	number:         0,
	timestamp:      time.Time{},
	prev_timestamp: time.Time{},
}

type SyncTime struct {
	Last  time.Duration
	Min   time.Duration
	Max   time.Duration
	Avg   time.Duration
	Count int64
}

var syncTime = SyncTime {
	Last: 0.00,
	Min: 0.00,
	Max: 0.00,
	Avg: 0.00,
	Count: 0,
}

func getSyncTime(block Block, local Local) SyncTime {
	syncTime.Count += 1
	syncTime.Last = local.timestamp.Sub(local.prev_timestamp)
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

func getBlockData() Block {
	client, err := ethclient.Dial(config.User.RpcKey)
	if err != nil {
		log.Fatal(err)
	}
	data, err := client.BlockByNumber(context.Background(), nil)
	if err != nil {
		log.Fatal(err)
	}

	block := Block{
		ParentHash:    data.ParentHash(),
		UncleHash:     data.UncleHash(),
		Coinbase:      data.Coinbase(),
		Root:          data.Root(),
		TxHash:        data.TxHash(),
		ReceiptHash:   data.ReceiptHash(),
		Difficulty:    data.Difficulty(),
		Number:        data.Number(),
		GasLimit:      data.GasLimit(),
		GasUsed:       data.GasUsed(),
		Time:          data.Time(),
		Extra:         data.Extra(),
		MixDigest:     data.MixDigest(),
		BaseFee:       data.BaseFee(),
	}

	return block
}

var isFirstCall = true
var num = new(big.Int).SetInt64(0)

func ScannerL1() L1 {
	block := getBlockData()

	if isFirstCall {
		num.Set(block.Number)
		isFirstCall = false
	}

	if block.Number.Cmp(num) > 0 {
		num.Set(block.Number)
		// push block to DB

		// Update the local timestamp
		local.prev_timestamp = local.timestamp
		local.timestamp = time.Now()

		// Calculate the sync time
		syncTime := getSyncTime(block, local)
		if (syncTime.Last.Seconds() > 9999999) {
			return L1{Block: block, SyncTime: syncTime}
		}
		fmt.Printf("\033[s\033[1A\033[2K\rL1 - Block number %d with id %s synced in %.2f seconds - avg sync time %.2f \033[u", L1.Block.Number, utils.FormatHash(block.ReceiptHash.Hex()), syncTime.Last.Seconds(), syncTime.Avg.Seconds())
	}
	return L1{}
}
