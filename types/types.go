package types

type Users struct {
    ID       string   `json:"id"`
    Mail     string   `json:"mail"`
    Password string   `json:"password"`
    Keys     []string `json:"keys"`
}

type Node struct {
	ID      int    `json:"id"`
	HealthID  int    `json:"health_id"`
	L1ID      int    `json:"l1_id"`
	L2ID      int    `json:"l2_id"`
	SystemID  int    `json:"system_id"`
}
