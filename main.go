package main

import (
	"bufio"
	"database/sql"
	"fmt"
	"os"
	"time"
	"strings"
	"strconv"


	_ "github.com/go-sql-driver/mysql"
)

func parseTimestamp(timestampStr string) (time.Time, error) {
    layout := "15:04:05.000 02/01/2006 -07:00"
    return time.Parse(layout, timestampStr)
}

func extractNumber(input string) (string) {
    // Find the index of "number:" in the input string
    index := strings.Index(input, "number:")
    substr := input[index+len("number:"):]
    number := strings.Split(substr, ",")
	tes := strings.ReplaceAll(number[0], "\t", "")
    return tes
}

func removeBraces(input string) string {
    output := strings.ReplaceAll(input, "{", "")
    output = strings.ReplaceAll(output, "}", "")
    output = strings.ReplaceAll(output, "\"", "")

    return output
}


const (
	logsFile           = "client/logs.txt"
	dbConnectionString = "root:tokenApi!@tcp(localhost:3306)/juno"
)

type Block struct {
	number    int64
	syncTime  int64
	hash      string
}

func main() {
	db, err := sql.Open("mysql", dbConnectionString)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		panic(err)
	}

	// Loop continuously to read new lines from the file
	for {
		file, err := os.Open(logsFile)
		if err != nil {
			panic(err)
		}
		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			line := scanner.Text()
			if len(line) > 0 {
				liner := strings.ReplaceAll(removeBraces(line), " ", "\t")
				lineParsed := strings.Split(liner, "\t")
				timestamp, err := parseTimestamp(lineParsed[0] + " " + lineParsed[1] + " " + lineParsed[2])
				if err != nil {
					fmt.Println(err)
				}
				syncTime := timestamp.Unix()
				number, _ := strconv.ParseInt(extractNumber(liner), 10, 64)
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

func storeBlock(db *sql.DB, block Block) {
	_, err := db.Exec(`INSERT INTO block (number, sync_time) VALUES (?, ?, ?, ?)`,
		block.number, block.syncTime, block.hash)

	if err != nil {
		fmt.Println("Error inserting block:", err)
	} else {
		fmt.Println("Inserted block number", block.number)
	}

	updateBlockSyncStats(db)
}

func updateBlockSyncStats(db *sql.DB) {
	_, err := db.Exec(`UPDATE block_stats
	SET synced = (SELECT MAX(number) FROM block),
		sync_time_now = (SELECT sync_time FROM block ORDER BY sync_time DESC LIMIT 1),
		sync_time_max = (SELECT MAX(sync_time) FROM block),
		sync_time_min = (SELECT MIN(sync_time) FROM block),
		sync_time_avg = (SELECT AVG(EXTRACT(EPOCH FROM sync_time)) FROM block)`)

	if err != nil {
		fmt.Println("Error updating block sync stats:", err)
	} else {
		fmt.Println("Updated block sync stats")
	}
}
