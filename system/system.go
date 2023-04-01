package system

import (
	"fmt"
	"time"

	"github.com/shirou/gopsutil/v3/disk"
	"github.com/shirou/gopsutil/v3/process"
	"myOsiris/network/config"
)

type Entity interface {
	Update(value float64)
}

type Cpu struct {
	id   string
	last float64
	min  float64
	max  float64
	avg  float64
}

func (c *Cpu) Update(value float64) {
	c.last = value
	if c.min == 0 || value < c.min {
		c.min = value
	}
	if value > c.max {
		c.max = value
	}
	c.avg = (c.avg + value) / 2
}

type Memory struct {
	id   string
	last float64
	min  float64
	max  float64
	avg  float64
}

func (m *Memory) Update(value float64) {
	m.last = value
	if m.min == 0 || value < m.min {
		m.min = value
	}
	if value > m.max {
		m.max = value
	}
	m.avg = (m.avg + value) / 2
}

type Storage struct {
	id   string
	last float64
	min  float64
	max  float64
	avg  float64
}

func (s *Storage) Update(value float64) {
	s.last = value
	if s.min == 0 || value < s.min {
		s.min = value
	}
	if value > s.max {
		s.max = value
	}
	s.avg = (s.avg + value) / 2
}

type Temp struct {
	id   string
	last float64
	min  float64
	max  float64
	avg  float64
}

func (t *Temp) Update(value float64) {
	t.last = value
	if t.min == 0 || value < t.min {
		t.min = value
	}
	if value > t.max {
		t.max = value
	}
	t.avg = (t.avg + value) / 2
}

type System struct {
	id      string
	cpu     Cpu
	memory  Memory
	storage Storage
	temp    Temp
}

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
	sys := System{
		id: "system",
		cpu: Cpu{
			id: "cpu",
		},
		memory: Memory{
			id: "memory",
		},
		storage: Storage{
			id: "storage",
		},
		temp: Temp{
			id: "temp",
		},
	}

	cpuPercent, _ := p.CPUPercent()
	sys.cpu.Update(cpuPercent)

	memInfo, _ := p.MemoryInfo()
	sys.memory.Update(float64(memInfo.RSS))

	diskInfo, _ := disk.Usage("/")
	sys.storage.Update(float64(diskInfo.Used))

	fmt.Printf("\033[s\033[1B\033[2K\rL3 - CPU: %.2f, Memory: %.2f, Storage: %.2f, Temp: %.2f\n\033[u", sys.cpu.last, sys.memory.last, sys.storage.last, sys.temp.last)
}