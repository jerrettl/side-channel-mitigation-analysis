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
    - To install on Fedora:
        ```
        git clone https://github.com/akopytov/sysbench
        cd sysbench
        sudo dnf -y install make automake libtool
        pkgconfig libaio-devel
        sudo dnf -y install mariadb-devel openssl-devel
        ./autogen.sh
        ./configure --without-mysql
        make -j
        sudo make install
        ```
- [Passmark](https://www.passmark.com/products/pt_linux/index.php)
    - To install on Arch Linux: `yay -S passmark-performancetest-bin`
    - To install on Fedora:
        - Download your operating system's version at: https://www.passmark.com/products/pt_linux/download.php
        - Extract the contents to a folder that you can access.
        - Inside of this file, should be an executable file called `pt_linux_...` where "`...`" is the version you downloaded. Take a note of the exact location of this file.
- [cryptsetup](https://gitlab.com/cryptsetup/cryptsetup/)
    - To install on Arch Linux: `sudo pacman -Sy cryptsetup`
    - To install on Fedora: `sudo dnf install cryptsetup`
- [7zip](https://github.com/p7zip-project/p7zip)
    - To install on Arch Linux: `sudo pacman -Sy p7zip`
    - To install on Fedora: `sudo dnf install p7zip`

Additionally, it is expected that the Linux operating system uses `systemd`. (You may run the command `systemd-analyze` to check this. Should the command succeed, `systemd` is installed.)

You are now ready to run the script.


## Using the Script

To run the script, you would start as follows:

```
./tester.sh
```

**Only if you are on Fedora**, you will need to manually provide the path to the Passmark executable. For example, if this file is located at `/path/to/the/script/pt_linux_...`, then you would start the script as follows:

```
PASSMARK_LOCATION="/other/path/to/the/other/script/pt_linux_..." ./tester.sh
```


## Output

During the execution of the script, you will see various output representing each benchmarking application. (You may need to provide your superuser password during the script to allow the benchmarks to run.)

After running the script, a new file will be created called `results.csv`. (There will be a few other files created from various benchmark applications, but these can be ignored.)

Each time the script is run, `results.csv` will add the results of that run to the last line of the file.


## Generating Graphs

Some basic graphs can be automatically generated based on `results.csv`. To do this, use the `create-graphs.py` script.

> Note: You must have the following Python dependencies installed:
>
> - `matplotlib`
> - `pandas`
>
> You may use `pip`, your package manager, or other means depending on your specific system's setup.

To generate graphs, run the following in a command-line environment:

```
python3 create-graphs.py
```

You may generate graphs with a specific CSV file by adding the name of that file:

```
python3 create-graphs.py <filename>
```

This will create two files, `results.pdf` and `results.csv`, for your use. Adjust the script as needed to isolate specific tests.
