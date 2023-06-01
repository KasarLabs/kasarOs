package system

import (
	"database/sql"
	"log"
	"time"

	"myOsiris/network/config"
	"myOsiris/types"

	"github.com/shirou/gopsutil/v3/disk"
	"github.com/shirou/gopsutil/v3/process"
)

func ScannerSystem(db *sql.DB, nodeId uint) {
	config := config.User
	processName := config.Client

	for {
		processList, _ := process.Processes()
		for _, p := range processList {
			name, _ := p.Name()
			if name == processName {
				TrackProcess(p, db, nodeId)
				time.Sleep(time.Second * 10)
			}
		}
	}
}

func TrackProcess(p *process.Process, db *sql.DB, nodeId uint) {
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
	rows, err := db.Query("INSERT INTO system_cpu (node_id, cpu_value) VALUES ($1, $2)", nodeId, sys.Cpu.Last)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	rows, err = db.Query("INSERT INTO system_memory (node_id, memory_value) VALUES ($1, $2)", nodeId, sys.Memory.Last)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	rows, err = db.Query("INSERT INTO system_storage (node_id, storage_value) VALUES ($1, $2)", nodeId, sys.Storage.Last)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	rows, err = db.Query("INSERT INTO system_temp (node_id, temp_value) VALUES ($1, $2)", nodeId, sys.Temp.Last)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
}
