package system

import (
	"fmt"
	"time"

	"github.com/shirou/gopsutil/v3/disk"
	"github.com/shirou/gopsutil/v3/process"
	"myOsiris/network/config"
	"myOsiris/types"
)

func ScannerSystem() {
	config := config.User
	processName := config.Client

	for {
		processList, _ := process.Processes()
		for _, p := range processList {
			name, _ := p.Name()
			if name == processName {
				TrackProcess(p)
				time.Sleep(time.Second)
			}
		}
	}
}

func TrackProcess(p *process.Process) {
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

	fmt.Printf("\033[s\033[1B\033[2K\rSystem - CPU: %.2f, Memory: %.2fgb, Storage: %.2fgb, Temp: %.2f\n\033[u", sys.Cpu.Last, sys.Memory.Last, sys.Storage.Last, sys.Temp.Last)
}