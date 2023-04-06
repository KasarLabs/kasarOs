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

To install a Starknet full node and start monitoring it please run the following command:
```bash
git clone https://github.com/kasarlabs/myOsiris
cd myOsiris
```

Next you'll need to run the installation/manager script.
You can chose to either to install and run a node (recomended):

```bash
bash setup.sh
```

Or also start the node monitoring using:

```bash
bash setup.sh --track
```

#### 1. Chose your client
Now you need to choose a client between:
- Papyrus from Starkware ([infos](https://github.com/starkware-libs/papyrus))
- Pathfinder from Equilibrium ([infos](https://github.com/eqlabs/pathfinder))
- Juno from Nethermind ([infos](https://github.com/NethermindEth/juno))

#### 2. Fill your node infos
Then you'll need to enter a **name** for your node (can be whatever), reference your **RPC url** (from any RPC provider, if you dont have one yet please check this tutorial [here](https://blog.infura.io/post/getting-started-with-infuras-ethereum-api)) and you can leave the **Osiris Key** field empty for now (coming soon).

<div align="center">
  <img src="https://s10.gifyu.com/images/Capture-video-du-05-04-2023-04_57_12.gif" height="441" width="624">
</div>

#### 3. Manage your node
If you did not start the tracker or you want to stop, restart or permanently delete your node you can launch the node manager again:

```bash
bash setup.sh
```

It will detect if one of the 3 clients is runing and propose you to manage it:

<div align="center">
  <img src="https://s10.gifyu.com/images/Capture-video-du-06-04-2023-14_17_50.gif" height="436" width="692">
</div>

## 📊 Data



At this point the following data is returned from the tracker

### System monitoring
#### CPU tracker
* [X]  `sys.cpu.last` Actual CPU usage
* [X]  `sys.cpu.max` Max CPU usage
* [X]  `sys.cpu.min` Min CPU usage
* [X]  `sys.cpu.avg` Average CPU usage
#### Memory tracker
* [X]  `sys.memory.last` Actual memory usage
* [X]  `sys.memory.max` Max memory usage
* [X]  `sys.memory.min` Min memory usage
* [X]  `sys.memory.avg` Average memory usage
#### Storage tracker
* [X]  `sys.storage.last` Actual storage usage
* [X]  `sys.storage.max` Max storage usage
* [X]  `sys.storage.min` Min storage usage
* [X]  `sys.storage.avg` Average storage usage
#### Temperature tracker
* [ ]  `sys.temp.last` Actual temperature
* [ ]  `sys.temp.max` Max temperature
* [ ]  `sys.temp.min` Min temperature
* [ ]  `sys.temp.avg` Average temperature

### L1 State

#### Last block data
* [X]  `l1.Block.ParentHash` Parent hash
* [X]  `l1.Block.UncleHash` Uncle hash
* [X]  `l1.Block.Coinbase` Coinbase
* [X]  `l1.Block.Root` State root
* [X]  `l1.Block.TxHash` Transactions root
* [X]  `l1.Block.ReceiptHash` Receipts root
* [X]  `l1.Block.Difficulty` Difficulty
* [X]  `l1.Block.Number` Block number
* [X]  `l1.Block.GasLimit` Gas limit
* [X]  `l1.Block.GasUsed` Gas used
* [X]  `l1.Block.Time` Timestamp
* [X]  `l1.Block.Extra` Extra data
* [X]  `l1.Block.MixDigest` Mix hash
* [X]  `l1.Block.BaseFee` Base fee per gas (optional)
#### Sync time
* [X]  `l1.SyncTime.Last` Last sync time
* [X]  `l1.SyncTime.Min` Minimum sync time
* [X]  `l1.SyncTime.Max` Maximum sync time
* [X]  `l1.SyncTime.Avg` Average sync time
* [X]  `l1.SyncTime.Count` Sync count

### L2 State
#### Block data
* [X]   `l2.Block.Hash` Block hash
* [X]   `l2.Block.Number` Block number
* [X]   `l2.Block.New_root` New root
* [X]   `l2.Block.Parent_hash` Parent hash
* [X]   `l2.Block.Sequencer_address` Sequencer address
* [X]  `l2.Block.Status` Status
* [X]  `l2.Block.Timestamp` Timestamp
* [X]  `l2.Block.Transactions` Transactions
* [X]  `l2.Block.Local` Local
#### Sync time
* [X]  `l2.SyncTime.Last` Last sync time
* [X]  `l2.SyncTime.Min` Minimum sync time
* [X]  `l2.SyncTime.Max` Maximum sync time
* [X]  `l2.SyncTime.Avg` Average sync time
* [X]  `l2.SyncTime.Count` Sync count


## 📍 Roadmap

This script is the first tool of the Osiris trilogy containing an API, and an online node manager + dashboard. This project is expecting a lot of updates and maintenance. Checkout what's next:

#### myOsiris
- Integration of [beerus light client]()
- Fast, Light and Full sync options
- Updated snapshot for fast sync
- More and more data + detailed config
#### OsirisAPI (soon)
- Get your nodes data from anywhere at any moment
#### Osiris (soon)
- The hearth of this project, the first Starknet node crawler and a personal space were you'll be able to check your node stats dashboard using OsirisAPI and myOsiris
#### Node docs (soon)
- A detailed doc around Starknet full nodes
- A comparison dashboard for each clients performances
#### Sequencer (soon)
- Work in progress

## 🌐 Contact us

This is a [KasarLabs](https://twitter.com/kasarlabs) project If you need any help about myOsiris or anything else related to Starknet please feel free to open an issue or contact us via telegram [here](https://t.me/antiyro).

<p align="center">
  <img src="https://i.ibb.co/Lts6dNk/logo-eau.png" height="75" width="75" alt="Sublime's custom image"/>
</p>