# using custom2 jupyter lab

Custom2 jupyter lab image requires the user to manage their own packages. Packages can be installed for both R and Python.


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
- start custom2 jupyter lab using following command. 
    ```
    custom2
    ```
    A _host_ip_ and _port_number_ will be
    printed at the end of output. Use a browser to navigate to
    ```host_ip:port_number``` and a jupyter lab login page will appear. At jupyter
    login page, use password to be _your_ username.
    Also, following additional arguments can be specified for the custom2 command:

    `-m|--memory` : This argument has default value 160g. Adjust based on maximum memory to reserve for container.

    `-e|--mmenv` : This argument specifies the micromamba environment name to use or create. Default value is `jupyterlab`. When a custom environment name is provided, the container will create or activate that specific micromamba environment for package isolation.

    `-s|--setupmode` : This flag starts the container in setup mode, providing direct bash shell access instead of launching Jupyter Lab. Useful for installing packages, debugging, or performing administrative tasks. Cannot be used simultaneously with `-e` flag.

    `-w|--workdir` : This argument specifies the working directory name relative to your personal disk mount. Default value is `workdir`. This allows you to customize which directory is mounted as the working directory inside the container.

    example usage with parameters:

    ```
    custom2 -m 200g               # start jupyter server with 200GB memory 
    custom2 -e myenv2             # start with custom micromamba environment 'myenv2'
    custom2 -s                    # start in setup mode (bash shell access)
    custom2 -e myenv2 -m 180g     # start with 'myenv2' environment and 180GB memory
    custom2 -w myproject          # use 'myproject' directory as working directory
    custom2 -w data -m 200g       # use 'data' directory with 200GB memory
    custom2 -e myenv3 -w data  # use 'myenv3' environment with 'data' working directory
    ```
- any data to be saved on the personal disk (to persist when personal disk is transferred to another VM) should be placed within the working directory path in the container (default: `/workdir`, or the custom directory specified with `-w` option).

- stop jupyter after finishing up to release resources using following command. 
    ```
    custom-stop
    ```
- to restart jupyter, just use ```custom2``` again with appropriate parameters or no parameters to use defaults.

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
- packages are installed into ```/mnt/disks/$USER/workdir/R-packages``` in local filesystem and accessed at the working directory's ```R-packages``` subfolder on the container filesystem

## 3. use custom2 jupyter lab on a personal, regular VM

### one time setup

See [initial setup doc](/docs/initial.md)  

### for regular use

- start jupyter using following command. A _host_ip_ and _port_number_ will be
printed at the end of output. Use a browser to navigate to
```host_ip:port_number``` and an jupyter login page will appear. At jupyter
login page, use username ```root``` and password to be _your_ username.
    ```
    custom2
    ```
- stop jupyter after finishing up to release resources using following command. 
    ```
    custom-stop
    ```
    to restart jupyter, just use ```custom2``` again.

## Appendix

Go to [appendix](/docs/appendix.md)
