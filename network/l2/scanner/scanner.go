package scanner

import (
	"bufio"
	"fmt"
	"os"
	"time"
	"strings"
	"strconv"
	"path/filepath"
	"myOsiris/network/l2/utils"

	_ "github.com/go-sql-driver/mysql"
)


const (
	logsFile           = "./client/logs.txt"
	dbConnectionString = "root:tokenApi!@tcp(localhost:3306)/juno"
)

type Block struct {
	number    int64
	syncTime  int64
	hash      string
}

func Scanner() {
	absPath, err := filepath.Abs(logsFile)
	if err != nil {
		fmt.Println(err)
	}

	// Loop continuously to read new lines from the file
	for {
		file, err := os.Open(absPath)
		if err != nil {
			panic(err)
		}
		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			line := scanner.Text()
			if len(line) > 0 {
				liner := strings.ReplaceAll(utils.RemoveBraces(line), " ", "\t")
				lineParsed := strings.Split(liner, "\t")
				timestamp, err := utils.ParseTimestamp(lineParsed[0] + " " + lineParsed[1] + " " + lineParsed[2])
				if err != nil {
					fmt.Println(err)
				}
				syncTime := timestamp.Unix()
				number, _ := strconv.ParseInt(utils.ExtractNumber(liner), 10, 64)
				block := Block{
					number:   number,
					syncTime: syncTime,
				}
				fmt.Println("block", block)
				// storeBlock(db, block)
			}
		}
		if err := scanner.Err(); err != nil {
			fmt.Println("Error scanning file:", err)
		}
		file.Close()
		time.Sleep(1 * time.Second) // wait for 1 second before checking the file again
	}
}