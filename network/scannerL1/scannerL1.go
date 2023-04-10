package scannerL1

import (
    "context"
    "fmt"
    "log"
    "math/big"
    "time"

    "github.com/ethereum/go-ethereum/ethclient"
    "myOsiris/network/config"
    "myOsiris/network/utils"
    "myOsiris/types"
)

var local = types.Local {
    Number:         0,
    Timestamp:      time.Time{},
    Prev_timestamp: time.Time{},
}

var syncTime = types.SyncTime{
    Last: 0.00,
    Min:  0.00,
    Max:  0.00,
    Avg:  0.00,
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
    num         = new(big.Int).SetInt64(0)
)

func ScannerL1() types.L1 {
    block := getBlockData()

    if isFirstCall {
        num.Set(block.Number)
        isFirstCall = false
    }

    if block.Number.Cmp(num) > 0 {
        num.Set(block.Number)

        // push block to DB

        // Update the local timestamp
        local.Prev_timestamp = local.Timestamp
        local.Timestamp = time.Now()

        // Calculate the sync time
        syncTime := getSyncTime(block, local)
        if syncTime.Last.Seconds() > 9999999 {
            return types.L1{Block: block, SyncTime: syncTime}
        }

        l1 := types.L1{Block: block, SyncTime: syncTime}
        fmt.Printf("\033[s\033[1A\033[2K\rL1 - Block number %d with id %s synced in %.2f seconds - avg sync time %.2f \033[u", l1.Block.Number, utils.FormatHash(l1.Block.ReceiptHash.Hex()), l1.SyncTime.Last.Seconds(), l1.SyncTime.Avg.Seconds())
    }

    return types.L1{}
}