use super::config::Config;
use std::thread;
use std::collections::HashMap;

pub fn enable_metrics(conf: &Config) 
{
    if !conf.metrics.enabled 
    {
        return;
    }
    metrics.enabled = true;
    //this function just check if we have a hostname env
    let host = match env::hostname() 
    {
        Ok(val) => val,
        Err(e) => panic!("No hostname env , error : {:?}", e),
    }
    //tag insertion using hashmap to find host  
    host = host.to_string();
    let tags: HashMap<String, String> = [("host".to_string(), host)].iter().cloned().collect();

    log.Info("Starting metrics", "url", conf.Metrics.Endpoint,
        "db", conf.Metrics.Database, "namespace", conf.Metrics.Namespace);
    let influxtag = thread::spawn(||
    { registry, 10*time.Second,conf.Metrics.Endpoint, conf.Metrics.Database,
        conf.Metrics.Username, conf.Metrics.Password, conf.Metrics.Namespace, tags
    })
    influxtag.join().unwrap();
}
