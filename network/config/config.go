package config

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

type Config struct {
	Name   string `json:"name"`
	Client string `json:"client"`
	RpcKey string `json:"rpc_key"`
	NodeID string `json:"node_id"`
}

func CheckConfig(filename string) error {
	file, err := os.Open(filename)
	if err != nil {
		return fmt.Errorf("error opening config file: %v", err)
	}
	defer file.Close()

	var config Config
	decoder := json.NewDecoder(file)
	err = decoder.Decode(&config)
	if err != nil {
		return fmt.Errorf("error decoding config file: %v", err)
	}

	if config.Name == "" {
		return fmt.Errorf("error: name is empty")
	}
	if config.Client == "" {
		return fmt.Errorf("error: client is empty")
	}
	if config.RpcKey == "" {
		return fmt.Errorf("error: rpc_key is empty")
	} else {
		resp, err := http.Get(config.RpcKey)
		if err != nil {
			return fmt.Errorf("error testing rpc_key: %v", err)
		} else {
			if resp.StatusCode != http.StatusOK {
				return nil
			}
		}
	}

	return nil
}

func LoadConfig() (Config, error) {
	configData, err := ioutil.ReadFile("./config.json")
	var config Config

	if err != nil {
		return config, err
	}

	err = json.Unmarshal(configData, &config)
	if err != nil {
		return config, err
	}

	return config, nil
}

var User, _ = LoadConfig()
