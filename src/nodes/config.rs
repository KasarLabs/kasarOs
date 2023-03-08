use serde::Deserialize;

#[derive(Deserialize)]
pub struct Config {
    pub reload_interval: String,
    pub chain_name: String,
    pub server_address: String,
    pub clients: Vec<ClientInfo>,
    pub metrics: MetricsConfig,
    pub infura_key: String,
    pub infura_endpoint: String,
    pub alchemy_key: String,
    pub alchemy_endpoint: String,
    pub etherscan_key: String,
    pub etherscan_endpoint: String,
}

#[derive(Deserialize)]
pub struct MetricsConfig {
    pub enabled: bool,
    pub endpoint: String,
    pub username: String,
    pub database: String,
    pub password: String,
    pub namespace: String,
}

#[derive(Deserialize)]
pub struct ClientInfo {
    pub url: String,
    pub name: String,
    pub kind: String,
    pub ratelimit: i32,
}