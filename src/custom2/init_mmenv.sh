
common_setup(){
       local envname="$1"
       local workdir="$2"
       # set password 
       expect -c "
       spawn bash -lc \"micromamba run -n $envname jupyter lab password\"
       expect \"Enter password:\"
       send \"\$env(USER)\\r\"
       expect \"Verify password:\"
       send \"\$env(USER)\\r\"
       expect eof
       "

       micromamba run -n "$envname" jupyter lab --generate-config && echo -e 'c.ServerApp.terminals_enabled = True\nc.FileContentsManager.delete_to_trash = False\nc.ContentsManager.allow_hidden = True' >> /jupyter/.jupyter/jupyter_lab_config.py

        # setup IRkernel if renv/activate.R or renv.lock exists, install and setup if not
        echo "workdir: $workdir"
        micromamba run -n "$envname" R -e "
            setwd('$workdir')

            # Clear .Rprofile to avoid duplicate entries
            if (file.exists('.Rprofile')) {
                file.remove('.Rprofile')
            }

            if (file.exists('renv/activate.R')) {
                # Regular restart: load existing renv environment
                
                # append micromamba envs path here directly without requiring .Rprofile
                .libPaths(c(\"/jupyter/micromamba/envs/$envname/lib/R/library\", .libPaths()))
                renv::load()
                cat('.libPaths(c(\"/jupyter/micromamba/envs/$envname/lib/R/library\", .libPaths()))',
                    file = '.Rprofile', append = TRUE, sep = '\n')
                IRkernel::installspec(user = FALSE)
            } else if (file.exists('renv.lock')) {
                # First time start via renv.lock: init and restore
                renv::init(bare=TRUE)
                cat('.libPaths(c(\"/jupyter/micromamba/envs/$envname/lib/R/library\", .libPaths()))',
                    file = '.Rprofile', append = TRUE, sep = '\n')
                renv::restore()
                renv::install(c('pbdZMQ', 'IRkernel', 'yaml'))
                IRkernel::installspec(user = FALSE)
            } else {
                # Fresh start: create new renv environment
                renv::init()
                cat('.libPaths(c(\"/jupyter/micromamba/envs/$envname/lib/R/library\", .libPaths()))',
                    file = '.Rprofile', append = TRUE, sep = '\n')
                renv::install(c('pbdZMQ', 'IRkernel', 'yaml'))
                IRkernel::installspec(user = FALSE)
            }
        "
        # first condition - regular restart (only load, don't init renv)
        # second condition - first time start via renv.lock (init_mmenv wont init since micromamba env already exists); (renv.lock must include IRkernel)
        # third condition - first time restart after clearing workdir (init_mmenv wont init renv since micromamba env already exists)

        # Print IP and port information
        local host_ip="${HOST_IP:-$(hostname -I | awk '{print $1}')}"
        local host_port="${HOST_PORT:-8787}"
        echo "================================"
        echo "JupyterLab will be available at:"
        echo "http://${host_ip}:${host_port}"
        echo "================================"

}

init_mmenv() {
    # Validate that both Python and R versions are specified together, or neither
    if [ -n "$3" ] && [ -z "$4" ]; then
        echo "Error: Both Python and R versions must be specified together."
        echo "Usage: jstart [envname] [python_version] [r_version]"
        echo "Example: jstart jupyterlab 3.11 4.4"
        return 1
    fi

    if [ -z "$3" ] && [ -n "$4" ]; then
        echo "Error: Both Python and R versions must be specified together."
        echo "Usage: jstart [envname] [python_version] [r_version]"
        echo "Example: jstart jupyterlab 3.11 4.4"
        return 1
    fi

    local envname="${1:-jupyterlab}"
    local workdir="${2:-${WORKDIR_PATH:-/workdir}}"
    local pyversion="${3:-3.10}"
    local rversion="${4:-4.3}"
    echo "init_mmenv called with envname='$envname' workdir='$workdir' pyversion='$pyversion' rversion='$rversion'"
    echo "WORKDIR_PATH environment variable = '$WORKDIR_PATH'"
    # Check if the environment exists
    if micromamba env list | grep -q "$envname"; then
        echo "$envname environment found. Activating and starting JupyterLab..."
        micromamba activate "$envname"

        common_setup "$envname" "$workdir"


        jupyter lab --allow-root --ip '0.0.0.0' --port '8787' --NotebookApp.token='' --NotebookApp.notebook_dir="$workdir" --no-browser
    else
        echo "$envname environment not found. Creating and starting JupyterLab..."
        # Create the environment

       # micromamba create -n "$envname" -y python=3.11.2 jupyterlab pandas -c conda-forge
       micromamba create -n "$envname" r-matrix python="$pyversion" r-base="$rversion" jupyterlab libxml2 xz zlib r-pbdzmq r-renv r-yaml zeromq pkg-config gcc_linux-64 gxx_linux-64 gfortran_linux-64 sysroot_linux-64 -c conda-forge -y


       # Activate the new environment
       micromamba activate "$envname"

        echo "workdirr: $workdir"
      # micromamba run -n "$envname" R -e 'renv::init(bare=TRUE); renv::install("IRkernel", prompt = FALSE); IRkernel::installspec(user = FALSE)'
      micromamba run -n "$envname" R -e "setwd('$workdir'); renv::init(bare=TRUE); cat('.libPaths(c(\"/jupyter/micromamba/envs/$envname/lib/R/library\", .libPaths()))', file = '.Rprofile', append = TRUE, sep = '\n'); renv::install(c('IRkernel', 'yaml'));"



        

       # micromamba install -c conda-forge r-matrix "r-base=4.3" -y 
       # R -e "install.packages(c('IRkernel', 'renv', 'yaml'), repos = 'https://cran.rstudio.com')"
       # R -e 'IRkernel::installspec(user = FALSE)'

       common_setup "$envname" "$workdir"

        # Start JupyterLab
        jupyter lab --allow-root --ip '0.0.0.0' --port '8787' --NotebookApp.token='' --NotebookApp.notebook_dir="$workdir" --no-browser
    fi
}
