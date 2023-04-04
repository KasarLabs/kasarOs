<div align="center">
  <img src="https://i.ibb.co/bPKp1wb/osiris.png" height="100" width="100">
  <br />
  <a href="https://github.com/kasarlabs/osiris/issues/new?assignees=&labels=bug&template=01_BUG_REPORT.md&title=bug%3A+">Report a Bug</a>
  ·
  <a href="https://github.com/kasarlabs/osiris/issues/new?assignees=&labels=enhancement&template=02_FEATURE_REQUEST.md&title=feat%3A+">Request a Feature</a>
  ·
  <a href="https://github.com/kasarlabs/osiris/discussions">Ask a Question</a>
</div>

<div align="center">
<br />

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/kasarlabs/osiris/ci.yml?branch=main)
[![Project license](https://img.shields.io/github/license/kasarlabs/osiris.svg?style=flat-square)](LICENSE)
[![Pull Requests welcome](https://img.shields.io/badge/PRs-welcome-ff69b4.svg?style=flat-square)](https://github.com/kasarlabs/osiris/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22)

</div>

# Osiris

This repo contains an easy to use Starknet full node installer and tracker/monitoring script that supports any clients available on Starknet and that will be used by Starknode plug'n'play to track its performances.

## 💻 Installation

(Recomended) To install a Starknet full node and start monitoring it please run the following command:
```bash
git clone https://github.com/kasarlabs/myOsiris | bash setup.sh --track
```
Or if you only want to setup a full node locally without tracking it you can run the following:
```bash
git clone https://github.com/kasarlabs/myOsiris | bash setup.sh
```

1. Now you need to choose a client between:
- Papyrus from Starkware ([infos](https://github.com/starkware-libs/papyrus))
- Pathfinder from Equilibrium ([infos](https://github.com/eqlabs/pathfinder))
- Juno from Nethermind ([infos](https://github.com/NethermindEth/juno))

2. Then you'll need to enter a **name** for your node (can be whatever), reference your **RPC url** (from any RPC provider, if you dont have one yet please check this tutorial [here](https://blog.infura.io/post/getting-started-with-infuras-ethereum-api)) and you can leave the **Osiris Key** field empty for now (coming soon).

## 📊 Data

The available data provided by the tracker :

* [X] System monitoring
    * [X] CPU tracker
      * [X] `cpu.now` Actual CPU usage
      * [X] `cpu.max` Max CPU usage
      * [X] `cpu.min` Min CPU usage
      * [X] `cpu.avg` Average CPU usage
    * [X] Memory tracker
      * [X] `ram.now` Actual memory usage
      * [X] `ram.max` Max memory usage
      * [X] `ram.min` Min memory usage
      * [X] `ram.avg` Average memory usage
    * [X] Storage tracker
      * [X] `storage.now` Actual storage usage
      * [X] `storage.max` Max storage usage
      * [X] `storage.min` Min storage usage
      * [X] `storage.avg` Average memory usage
    * [X] Network tracker
      * [X] `network.read_now` Actual network reading usage
      * [X] `network.read_max` Max network reading usage
      * [X] `network.read_min` Min netowrk reading usage
      * [X] `network.read_avg` Average netork usage
      * [X] `network.write_now` Actual network write usage
      * [X] `network.write_max` Max network write usage
      * [X] `network.write_min` Min netowrk write usage
      * [X] `network.write_avg` Average write usage
* [ ] Client mintoring
    * [ ] Block tracker
      * [ ] `block.synced` Last block synced
      * [ ] `block.size_now` Last block size
      * [ ] `block.size_max` Max block size
      * [ ] `block.size_min` Min block size
      * [ ] `block.size_avg` Average block size
      * [ ] `block.syncTime_now` Last block sync time
      * [ ] `block.syncTime_max` Max block sync time
      * [ ] `block.syncTime_avg` Min block sync time
      * [ ] `block.size_avg` Average block sync time

## 📍 Roadmap

* [X] System monitoring
    * [X] CPU tracking
    * [X] Memory tracking
    * [X] Storage tracking
    * [X] Network tracking
* [ ] Client mintoring
    * [ ] Blocks tracking
* [ ] API
    * [ ] Local API
    * [ ] Shared DB + Remote API
* [ ] Hosted dashboard
    * [ ] User auth
    * [ ] Dashboard
## 🌐 Contact us

This is a [KasarLabs](https://twitter.com/kasarlabs) project If you need any help about Osiris or anything else related to Starknet please feel free to open an issue or contact us via telegram [here](https://t.me/antiyro).

<p align="center">
  <img src="https://i.ibb.co/BNjdJdg/Kasarlabs-logo.png" height="50" width="50" alt="Sublime's custom image"/>
</p>