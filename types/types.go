package types

import (
    "time"
)

type Users struct {
    ID       string
    Keys     []string
}

type Providers struct {
    ID       string
    Keys     []string
	Nodes	 []Node
}

type Node struct {
	ID     string
	L1     L1
	L2     L2
	System System
}

type L1 struct {
	ID		 string
    Block    L1Block
    SyncTime SyncTime
}

type L2 struct {
	ID   	string
    Block    L2Block
    SyncTime SyncTime
}

type L1Block struct {
	ID					string
    ParentHash    string    `json:"parentHash"       gencodec:"required"`
    UncleHash     string    `json:"sha3Uncles"       gencodec:"required"`
    Coinbase      string	`json:"miner"`
    Root          string    `json:"stateRoot"        gencodec:"required"`
    TxHash        string    `json:"transactionsRoot" gencodec:"required"`
    ReceiptHash   string    `json:"receiptsRoot"     gencodec:"required"`
    Difficulty    int64       `json:"difficulty"       gencodec:"required"`
    Number        int64       `json:"number"           gencodec:"required"`
    GasLimit      uint64         `json:"gasLimit"         gencodec:"required"`
    GasUsed       uint64         `json:"gasUsed"          gencodec:"required"`
    Time          uint64         `json:"timestamp"        gencodec:"required"`
    Extra         []byte         `json:"extraData"        gencodec:"required"`
    MixDigest     string    `json:"mixHash"`
    BaseFee       int64       `json:"baseFeePerGas" rlp:"optional"`
}

type L2Block struct {
	ID					string
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

type Entity interface {
	Update(value float64)
}

type Cpu struct {
	ID   string
	Last float64
	Min  float64
	Max  float64
	Avg  float64
}

type Memory struct {
	ID   string
	Last float64
	Min  float64
	Max  float64
	Avg  float64
}

type Storage struct {
	ID   string
	Last float64
	Min  float64
	Max  float64
	Avg  float64
}

type Temp struct {
	ID   string
	Last float64
	Min  float64
	Max  float64
	Avg  float64
}

type System struct {
	ID      string
	Cpu     Cpu
	Memory  Memory
	Storage Storage
	Temp    Temp
}

func (c *Cpu) Update(value float64) {
	c.Last = value
	if c.Min == 0 || value < c.Min {
		c.Min = value
	}
	if value > c.Max {
		c.Max = value
	}
	c.Avg = (c.Avg + value) / 2
}

func (m *Memory) Update(value float64) {
	m.Last = value / (1024 * 1024 * 1024)
	if m.Min == 0 || value < m.Min {
		m.Min = value
	}
	if value > m.Max {
		m.Max = value
	}
	m.Avg = (m.Avg + value) / 2
}

func (s *Storage) Update(value float64) {
	s.Last = value / (1024 * 1024 * 1024)
	if s.Min == 0 || value < s.Min {
		s.Min = value
	}
	if value > s.Max {
		s.Max = value
	}
	s.Avg = (s.Avg + value) / 2
}

func (t *Temp) Update(value float64) {
	t.Last = value
	if t.Min == 0 || value < t.Min {
		t.Min = value
	}
	if value > t.Max {
		t.Max = value
	}
	t.Avg = (t.Avg + value) / 2
}