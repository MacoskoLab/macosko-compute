# using rstudio

## 1. use rstudio on shared, high memory VM
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
- start rstudio using following command. 
    ```
    rstudio
    ```
    A _host_ip_ and _port_number_ will be
    printed at the end of output. Use a browser to navigate to
    ```host_ip:port_number``` and an rstudio login page will appear. At rstudio
    login page, use username ```root``` and password to be _your_ username.
    Also, following additional arguments can be specified for the rstudio command:

    `-m|--memory` : This argument has default value `160g`. Adjuct based on maximum memory to reserve for container.

    `-i|--image` : This argument has default value `std` to included preintalled libraries like Seurat. If `basic` is passed, then no libraries are preinstalled. Packages installed within a container running `basic` image would be ported to another VM along with personal disk.

    example usage with parameters:

    ```
    rstudio -m 200g -i basic # start rstudio server with 200GB memory and no preinstalled libraries
    ```
- any data to be saved on the personal disk (to persist when personal disk is tranfered to another VM) should be placed within the path `/rstudio/workdir` in the rstudio container.

- stop rstudio after finishing up to release resources using following command. 
    ```
    rstudio-stop
    ```
- to restart rstudio, just use ```rstudio``` again with appropriate parameters.

## 2. use rstudio on a personal, regular VM

### one time setup

See [initial setup doc](/docs/initial.md)  

### for regular use

- start rstudio using following command. A _host_ip_ and _port_number_ will be
printed at the end of output. Use a browser to navigate to
```host_ip:port_number``` and an rstudio login page will appear. At rstudio
login page, use username ```root``` and password to be _your_ username.
    ```
    rstudio
    ```
- stop rstudio after finishing up to release resources using following command. 
    ```
    rstudio-stop
    ```
    to restart rstudio, just use ```rstudio``` again.

## 3. project management using renv
- renv can be used from within rstudio to manage separate library installations
for different projects. Create project directories inside the
```/workdir``` from within rstudio.

## Appendix

Go to [appendix](/docs/appendix.md)


