# BlockSpace - SmartContracts

This is the main repo for the project's smart contracts. The core idea and innovation is based on the SSTORE2 library's READ & WRITE functions. It makes read and write operations at the fraction of the costs (of SLOAD, SSTORE).

What and how it is doing, please see the diagram below.

![Alt text](./Blockchain_deployment.png?raw=true "Title")

# Gas savings

### SLOAD Cost (data read)

Reading data is a lot cheaper compared to native SLOAD operations (native solidity storage).

After reading 32 bytes `SSTORE2.read` becomes the cheaper option, and `SSTORE2Map.read` becomes cheaper when reading 33 bytes or more.

| Size (bytes) | SLOAD     | SLOAD2 | SLOAD2 - Map | Savings | Savings (map) |
|--------------|-----------|--------|--------------|---------|---------------|
|            0 |     2.679 |  3.102 |        5.258 |   0,86x |         0,51x |
|            2 |     2.852 |  3.108 |        5.261 |   0,92x |         0,54x |
|           32 |     4.914 |  3.108 |        5.264 |   1,58x |         0,93x |
|           33 |     7.067 |  3.114 |        5.267 |   2,27x |         1,34x |
|           64 |     7.067 |  3.114 |        5.270 |   2,27x |         1,34x |
|           96 |     9.220 |  3.120 |        5.276 |   2,96x |         1,75x |
|          128 |    11.373 |  3.126 |        5.282 |   3,64x |         2,15x |
|          256 |    19.985 |  3.150 |        5.306 |   6,34x |         3,77x |
|          512 |    37.209 |  3.198 |        5.355 |  11,64x |         6,95x |
|         1024 |    71.659 |  3.296 |        5.454 |  21,74x |        13,14x |
|        24576 | 1.349.161 |  7.627 |        9.805 | 176,89x |       137,60x |


### SSTORE Cost (data writes)

Writing data is also cheaper than native SSTORE operations (native solidity storage), but gains become apparent after higher data sizes.

After writing 32 bytes `SSTORE2.write` becomes the cheaper option, and `SSTORE2Map.write` becomes cheaper only when writing 128 bytes or more.

| Size (bytes) | SSTORE     | SSTORE2   | SSTORE2 - Map | Savings | Savings (map) |
|--------------|------------|-----------|---------------|---------|---------------|
|            0 |      2.660 |    35.323 |        73.565 |   0,08x |         0,04x |
|            2 |     22.607 |    35.819 |        74.061 |   0,63x |         0,31x |
|           32 |     44.810 |    41.891 |        80.218 |   1,07x |         0,56x |
|           33 |     66.980 |    42.187 |        80.514 |   1,59x |         0,83x |
|           64 |     66.980 |    48.459 |        86.870 |   1,38x |         0,77x |
|           96 |     89.150 |    55.027 |        93.523 |   1,62x |         0,95x |
|          128 |    111.320 |    61.595 |       100.175 |   1,81x |         1,11x |
|          256 |    200.000 |    87.869 |       126.786 |   2,28x |         1,58x |
|          512 |    377.360 |   140.417 |       180.010 |   2,69x |         2,10x |
|         1024 |    732.080 |   245.522 |       286.475 |   2,98x |         2,56x |
|        24576 | 13.878.890 | 4.148.020 |     4.244.998 |   3,35x |         3,27x |


> **Notice:** gas savings may change in future Ethereum hard-forks.

> **Notice x2:** due to contract code limits 24576 bytes is the maximum amount of data that can be written in a single pointer / key. Attempting to write more will result in failure this is why the idea of writing large amount of data in chunks.

## Using this repo

0. Prerequisite: create a .env file with
1. Clone this repository then install dependencies.
`npm ci`
2. Build contracts and generate typechain typeings.
`npx hardhat compile`
3. Run deployment script which will puts the deployments and the 2 files (1 image, 1 pdf) onto the mumbai network. (You can try matic as well).
`npx hardhat run scripts/deploy.ts --network mumbai`

### .env FIle

You will need to create an .env file in the root directory. It needs to contain the following variables:

- MY_PRIV_KEYS [my wallets priv key]
- MUMBAI_PROVIDER [moralis](https://moralis.io/) | [infura](https://infura.io/) | [alchemy](https://www.alchemy.com/)
- MATIC_PROVIDER [moralis](https://moralis.io/) | [infura](https://infura.io/) | [alchemy](https://www.alchemy.com/)