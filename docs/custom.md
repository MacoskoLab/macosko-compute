# using custom jupyter lab

Custom jupyter lab image requires the user to manage their own packages. Packages can be installed for both R and Jupyter.


## 1. use jupyter lab on shared, high memory VM
- log in to VM `highmem1` if not already logged in
- mount personal disk using following command
    ```
    mountdisk <disk-name>
    ```
- start tmux using following command if first use
    ```
    tmux
    ```
    for subsequent use, use the following command to attach to tmux session
    ```
    tmux attach
    ```
- start custom jupyter lab using following command. 
    ```
    custom
    ```
    A _host_ip_ and _port_number_ will be
    printed at the end of output. Use a browser to navigate to
    ```host_ip:port_number``` and an jupyter login page will appear. At jupyter
    login page, use username ```root``` and password to be _your_ username.
    Also, following additional arguments can be specified for the jupyter command:

    `-m|--memory` : This argument has default value 160g. Adjuct based on maximum memory to reserve for container.


    example usage with parameters:

    ```
    custom -m 200g -i basic # start jupyter server with 200GB memory 
    ```
- any data to be saved on the personal disk (to persist when personal disk is tranfered to another VM) should be placed within the path `/jupyter/workdir` in the jupyter container.

- stop jupyter after finishing up to release resources using following command. 
    ```
    custom-stop
    ```
- to restart jupyter, just use ```custom``` again with appropriate parameters or no parameters to use defaults.

## 2. installing packages

### 2.1 installing python packages

- start console in jupyter lab
- enter ```bash```
- install packages via ```micromamba``` into current enviromment
    - e.g ```micromamba install pseudorandom -c conda-forge``` to install package ```pseudorandom```
- packages are installed into ```/mnt/disks/$USER/jupyter/micromamba``` in local filesystem and accessed at ```/jupyter/micromamba``` on the container filesystem

### 2.2 installing R packages

- start console in jupyter lab
- start ```R``` in console
- install R packages as usual via ```install.packages``` e.g. ```install.packages("qs")``` to install package ```qs```
- packages are installed into ```/mnt/disks/$USER/workdir/R-packages``` in local filesystem and accessed at ```/workdir/R-packages``` on the container filesystem

## 3. use custom jupyter lab on a personal, regular VM

### one time setup

See [initial setup doc](/docs/initial.md)  

### for regular use

- start jupyter using following command. A _host_ip_ and _port_number_ will be
printed at the end of output. Use a browser to navigate to
```host_ip:port_number``` and an jupyter login page will appear. At jupyter
login page, use username ```root``` and password to be _your_ username.
    ```
    custom
    ```
- stop jupyter after finishing up to release resources using following command. 
    ```
    custom-stop
    ```
    to restart jupyter, just use ```custom``` again.

## Appendix

Go to [appendix](/docs/appendix.md)
