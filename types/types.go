package types

import (
    "github.com/ethereum/go-ethereum/common"
    "math/big"
    "time"
)

type Users struct {
    ID       string   `json:"id"`
    Mail     string   `json:"mail"`
    Password string   `json:"password"`
    Keys     []string `json:"keys"`
}

type Node struct {
	ID      int    `json:"id"`
	HealthID  int    `json:"health_id"`
	L1ID      int    `json:"l1_id"`
	L2ID      int    `json:"l2_id"`
	SystemID  int    `json:"system_id"`
}

type L1 struct {
    Block    L1Block
    SyncTime SyncTime
}

type L1Block struct {
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

type L2Block struct {
	Hash				string
	Number				int64
	New_root			string
    Parent_hash			string
    Sequencer_address	string
    Status				string
    Timestamp			int64
    Transactions		[]string
	Local 				Local
}

type Local struct {
    Number          int64
    Timestamp       time.Time
    Prev_timestamp  time.Time
}

type SyncTime struct {
    Last  time.Duration
    Min   time.Duration
    Max   time.Duration
    Avg   time.Duration
    Count int64
}