package utils

import (
    "fmt"
    "regexp"
    "strings"
    "time"

    "myOsiris/network/config"

    _ "github.com/go-sql-driver/mysql"
)

func ExtractTimestamp(line string) (int64, error) {
    var timestampStr string
    var layout string

    switch config.User.Client {
    case "juno":
        layout = "15:04:05.000 02/01/2006 -07:00"
        parts := strings.Split(line, "\t")
        date := parts[0] + " " + parts[1] + " " + parts[2]
        timestampStr = date
    case "papyrus", "pathfinder":
        layout = "2006-01-02T15:04:05.999999Z"
        parts := strings.Split(line, "\t")
        ansiRegex := regexp.MustCompile(`\x1b\[[0-9;]*m`)
        timestampStr = ansiRegex.ReplaceAllString(parts[0], "")
    default:
        return time.Time{}.Unix(), fmt.Errorf("unknown user.Client")
    }

    t, err := time.Parse(layout, timestampStr)
    if err != nil {
        return time.Time{}.Unix(), fmt.Errorf("error parsing date: %v", err)
    }

    return t.Unix(), nil
}

func ExtractNumber(input string) string {
    switch config.User.Client {
    case "juno":
        index := strings.Index(input, "number:")
        substr := input[index+len("number:"):]
        number := strings.Split(substr, ",")
        res := strings.ReplaceAll(number[0], "\t", "")
        return res
    case "papyrus", "pathfinder":
        if strings.Contains(input, "Updated StarkNet") {
            return "0"
        }

        words := strings.Fields(input)
        for i, word := range words {
            if word == "block" && i < len(words)-1 {
                blockNumber := words[i+1]
                return blockNumber
            }
        }
    }
    panic("unknown user.Client")
}

func RemoveBraces(input string) string {
    output := strings.ReplaceAll(input, "{", "")
    output = strings.ReplaceAll(output, "}", "")
    output = strings.ReplaceAll(output, "\"", "")

    return output
}
