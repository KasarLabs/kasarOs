package scannerL1

import (
	"context"
	"log"
	"math/big"
	"fmt"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
	"myOsiris/network/config"
)

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

func ScannerL1() {
	block := getBlockData()

	if isFirstCall {
		num.Set(block.Number)
		isFirstCall = false
	}

	if block.Number.Cmp(num) > 0 {
		num.Set(block.Number)
		// push block to DB
		fmt.Printf("\033[1A\033[2K\rL1 SyncData : %d %s\n", block.Number, block.TxHash)
	}
}
