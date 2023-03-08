use super::config::Config;

pub fn enable_metrics(conf: &Config) {
    if !conf.metrics.enabled {
        return;
    }

    //TO DO
}