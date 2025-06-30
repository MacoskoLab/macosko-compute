# using jupyter lab

## 1. use jupyter lab on shared, high memory VM
- log in to VM `highmem1` if not already logged in
- mount personal disk using following command
    ```
    mountdisk <disk-name>
    ```
- start jupyter using following command. 
    ```
    jupyter
    ```
    A _host_ip_ and _port_number_ will be
    printed at the end of output. Use a browser to navigate to
    ```host_ip:port_number``` and an jupyter login page will appear. At jupyter
    login page, use username ```root``` and password to be _your_ username.
    Also, following additional arguments can be specified for the jupyter command:

    `-m|--memory` : This argument has default value 160g. Adjuct based on maximum memory to reserve for container.

    `-i|--image` : This argument has default value `std` to included preintalled libraries like Seurat. If `basic` is passed, then no libraries are preinstalled. Packages installed within a container running `basic` image would be ported to another VM along with personal disk.

    example usage with parameters:

    ```
    jupyter -m 200g -i basic # start jupyter server with 200GB memory and no preinstalled libraries
    ```
- any data to be saved on the personal disk (to persist when personal disk is tranfered to another VM) should be placed within the path `/jupyter/workdir` in the jupyter container.

- stop jupyter after finishing up to release resources using following command. 
    ```
    jupyter-stop
    ```
- to restart jupyter, just use ```jupyter``` again with appropriate parameters.


## 2. use jupyter lab on a personal, regular VM

### one time setup

See [initial setup doc](/docs/initial.md)  

### for regular use

- start jupyter using following command. A _host_ip_ and _port_number_ will be
printed at the end of output. Use a browser to navigate to
```host_ip:port_number``` and an jupyter login page will appear. At jupyter
login page, use username ```root``` and password to be _your_ username.
    ```
    jupyter
    ```
- stop jupyter after finishing up to release resources using following command. 
    ```
    jupyter-stop
    ```
    to restart jupyter, just use ```jupyter``` again.

## Appendix

Go to [appendix](/docs/appendix.md)
