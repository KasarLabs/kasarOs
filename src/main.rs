use log::{error, info};
use std::env;
use std::fs::File;
mod nodes;
use nodes::config::{Config, MetricsConfig, ClientInfo};
use nodes::reporting::{enable_metrics};
use toml::de::Error as TomlError;


fn main() {
    // Initialize logger that writes to stderr
    env_logger::init();

    // Check if program was invoked with at least one command-line argument
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        error!("Missing command-line argument");
        std::process::exit(1);
    }

    // Attempt to open file whose path is given as first command-line argument
    let file_path = &args[1];
    match File::open(file_path) {
        Ok(_) => {
            info!("Successfully opened file: {}", file_path);
        },
        Err(e) => {
            error!("Failed to open file {}: {}", file_path, e);
            std::process::exit(1);
        }
    }

    let contents = match std::fs::read_to_string(file_path) {
        Ok(contents) => contents,
        Err(e) => {
            error!("Failed to read file {}: {}", file_path, e);
            std::process::exit(1);
        }
    };
    
    let config: Result<Config, TomlError> = toml::from_str(&contents);
    match config {
        Ok(config) => {
            enable_metrics(&config)
        },
        Err(err) => {
            eprintln!("Error: {:?}", err);
            std::process::exit(1);
        }
    };

}
