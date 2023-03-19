package config

import (
	"encoding/json"
	"io/ioutil"
)

type Config struct {
	Name       string `json:"name"`
	Client     string `json:"client"`
	RPCKey     string `json:"rpc_key"`
	OsirisKey  string `json:"osiris_key"`
}

func LoadConfig() (Config, error) {
	configData, err := ioutil.ReadFile("config.json")
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
