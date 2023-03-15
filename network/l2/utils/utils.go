package utils

import (
	"time"
	"strings"

	_ "github.com/go-sql-driver/mysql"
)

func ParseTimestamp(timestampStr string) (time.Time, error) {
    layout := "15:04:05.000 02/01/2006 -07:00"
    return time.Parse(layout, timestampStr)
}

func ExtractNumber(input string) (string) {
    // Find the index of "number:" in the input string
    index := strings.Index(input, "number:")
    substr := input[index+len("number:"):]
    number := strings.Split(substr, ",")
	res := strings.ReplaceAll(number[0], "\t", "")
    return res
}

func RemoveBraces(input string) string {
    output := strings.ReplaceAll(input, "{", "")
    output = strings.ReplaceAll(output, "}", "")
    output = strings.ReplaceAll(output, "\"", "")

    return output
}