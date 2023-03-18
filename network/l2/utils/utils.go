package utils

import (
	"time"
	"strings"
    "fmt"
    "regexp"

	_ "github.com/go-sql-driver/mysql"
)

var client = "papyrus"

func ExtractTimestamp(line string) (int64, error) {
    var timestampStr string
    var layout string
    if (client == "juno") {
        layout = "15:04:05.000 02/01/2006 -07:00"
        parts := strings.Split(line, "\t")
        date := parts[0] + " " + parts[1] + " " + parts[2]
        timestampStr = date
    } else if (client == "papyrus") {
        layout = "2006-01-02T15:04:05.999999Z"
        parts := strings.Split(line, "\t")
        ansiRegex := regexp.MustCompile(`\x1b\[[0-9;]*m`)
        timestampStr = ansiRegex.ReplaceAllString(parts[0], "")
    } else {
        return time.Time{}.Unix(), fmt.Errorf("unknown client")
    }
    t, err := time.Parse(layout, timestampStr)
    if err != nil {
        return time.Time{}.Unix(), fmt.Errorf("error parsing date: %v", err)
    }
    fmt.Println(t.Unix())
    return t.Unix(), nil
}

func ExtractNumber(input string) (string) {
    if (client == "juno") {
        index := strings.Index(input, "number:")
        substr := input[index+len("number:"):]
        number := strings.Split(substr, ",")
        res := strings.ReplaceAll(number[0], "\t", "")
        return res
    } else if (client == "papyrus") {
        words := strings.Fields(input)
        for i, word := range words {
            if word == "block" && i < len(words)-1 {
                blockNumber := words[i+1]
                return blockNumber
            }
        }
    }
    return "10"
}

func RemoveBraces(input string) string {
    output := strings.ReplaceAll(input, "{", "")
    output = strings.ReplaceAll(output, "}", "")
    output = strings.ReplaceAll(output, "\"", "")

    return output
}