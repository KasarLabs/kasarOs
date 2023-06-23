package system

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"myOsiris/network/config"
	"myOsiris/types"

	"github.com/google/uuid"
	"github.com/shirou/gopsutil/v3/disk"
	"github.com/shirou/gopsutil/v3/process"
)

type InputSystem struct {
	NodeID  uint
	Cpu     float64
	Memory  float64
	Storage float64
	Temp    float64
}

func ScannerSystem(baseUrl string, nodeId uint, providerId uuid.UUID) {
	config := config.User
	processName := config.Client
	urlEndpoint := baseUrl + "node/system/add?provider_id=" + providerId.String()

	for {
		processList, _ := process.Processes()
		for _, p := range processList {
			name, _ := p.Name()
			if name == processName {
				TrackProcess(p, urlEndpoint, nodeId)
				time.Sleep(time.Second * 60)
			}
		}
	}
}

func TrackProcess(p *process.Process, url string, nodeId uint) {
	sys := types.System{
		ID: "system",
		Cpu: types.Cpu{
			ID: "cpu",
		},
		Memory: types.Memory{
			ID: "memory",
		},
		Storage: types.Storage{
			ID: "storage",
		},
		Temp: types.Temp{
			ID: "temp",
		},
	}

	cpuPercent, _ := p.CPUPercent()
	sys.Cpu.Update(cpuPercent)

	memInfo, _ := p.MemoryInfo()
	sys.Memory.Update(float64(memInfo.RSS))

	diskInfo, _ := disk.Usage("/")
	sys.Storage.Update(float64(diskInfo.Used))

	data := InputSystem{
		NodeID:  nodeId,
		Cpu:     sys.Cpu.Last,
		Memory:  sys.Memory.Last,
		Storage: sys.Storage.Last,
		Temp:    sys.Temp.Last,
	}
	jsonData, err := json.Marshal(data)
	if err != nil {
		fmt.Println("Error system:", err)
		return
	}
	request, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		fmt.Println("Error system:", err)
		return
	}
	request.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	response, err := client.Do(request)
	if err != nil {
		fmt.Println("Error system:", err)
		return
	}
	response.Body.Close()
}
