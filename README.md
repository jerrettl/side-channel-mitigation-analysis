# CAP 6135 Project - Analysis of Side-Channel Mitigation Performance

This repository contains a script, `tester.sh`, that will collect various performance metrics.

The script is written in Linux bash, and is thus expected to be run within a Linux-based environment.

## Requirements

To run this script, the following benchmarking tools must be installed:

> Note: To install some of these packages on Arch Linux (or similar operating systems), you may want to have a package manager installed that gives access to the Arch User Repository.
>
> One example of this is `yay`, where installation instructions can be found at: https://github.com/Jguer/yay?tab=readme-ov-file#installation

- [Sysbench](https://github.com/akopytov/sysbench)
    - To install on Arch Linux: `sudo pacman -Sy sysbench`
- [Passmark](https://www.passmark.com/products/pt_linux/index.php)
    - To install on Arch Linux: `yay -S passmark-performancetest-bin`
- [Blender Open Data Benchmark](https://opendata.blender.org)
    - You should download the "Linux CLI" option on the project's download page, and extract the contents to a folder that you can access.
    - Inside of this file, should be an executable file called `benchmark-launcher-cli`. Take a note of the exact location of this file.
- [7zip](https://github.com/p7zip-project/p7zip)
    - To install on Arch Linux: `sudo pacman -Sy p7zip`

The following non-benchmarking tools must be installed:

- [jq](https://github.com/jqlang/jq)
    - To install on Arch Linux: `sudo pacman -Sy jq`

Additionally, it is expected that the Linux operating system uses `systemd`. (You may run the command `systemd-analyze` to check this. Should the command succeed, `systemd` is installed.)


## Setup

Before running the script, there is an additional step required to properly begin benchmarking. Blender Open Data Benchmark must first download the scene files it needs. To do this, see the following:

- In a terminal, navigate to the folder that contains `benchmark-launcher-cli`, as retrieved in the previous section.
- Run: `./benchmark-launcher-cli blender download 4.0.0`
- Run: `./benchmark-launcher-cli scenes download monster --blender-version 4.0.0`

You are now ready to run the script.


## Using the Script

To run the script, in a terminal first navigate to the location of `tester.sh`. Then, you will need to recall the location of `benchmark-launcher-cli`. For example, if this file is located at `/path/to/the/script/benchmark-launcher-cli`, then you would start the script as follows:

```
BLENDER_BENCHMARK_LOCATION="/path/to/the/script/benchmark-launcher-cli" tester.sh
```


## Output

During the execution of the script, you will see various output representing each benchmarking application. (You may need to provide your superuser password during the script to allow the benchmarks to run.)

After running the script, a new file will be created called `results.csv`. (There will be a few other files created from various benchmark applications, but these can be ignored.)

Each time the script is run, `results.csv` will add the results of that run to the last line of the file.
