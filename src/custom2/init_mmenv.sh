
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
        micromamba run -n "$envname" R -e "setwd('$workdir'); if (file.exists('renv/activate.R')) { renv::load(); IRkernel::installspec(user = FALSE) } else if (file.exists('renv.lock')) { renv::init(bare=TRUE); renv::restore(); renv::install(c('pbdZMQ', 'IRkernel', 'yaml')); IRkernel::installspec(user = FALSE) } else { renv::init(); renv::install(c('pbdZMQ','IRkernel', 'yaml')); IRkernel::installspec(user = FALSE) }"
        # first condition - regular restart (only load, don't init renv)
        # second condition - first time start via renv.lock (init_mmenv wont init since micromamba env already exists); (renv.lock must include IRkernel)
        # third condition - first time restart after clearing workdir (init_mmenv wont init renv since micromamba env already exists)


}

init_mmenv() {
    local envname="${1:-jupyterlab}"
    local workdir="${2:-${WORKDIR_PATH:-/workdir}}"
    echo "DEBUG: init_mmenv called with envname='$envname' workdir='$workdir'"
    echo "DEBUG: WORKDIR_PATH environment variable = '$WORKDIR_PATH'"
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
       micromamba create -n "$envname" r-matrix python=3.10 r-base=4.3 jupyterlab libxml2 xz zlib r-pbdzmq r-renv r-yaml zeromq pkg-config gcc_linux-64=13 gxx_linux-64=13 sysroot_linux-64 -c conda-forge -y


       # Activate the new environment
       micromamba activate "$envname"

        echo "workdirr: $workdir"
      # micromamba run -n "$envname" R -e 'renv::init(bare=TRUE); renv::install("IRkernel", prompt = FALSE); IRkernel::installspec(user = FALSE)'
      micromamba run -n "$envname" R -e "setwd('$workdir'); renv::init(bare=TRUE); renv::install(c('IRkernel', 'yaml'));"



        

       # micromamba install -c conda-forge r-matrix "r-base=4.3" -y 
       # R -e "install.packages(c('IRkernel', 'renv', 'yaml'), repos = 'https://cran.rstudio.com')"
       # R -e 'IRkernel::installspec(user = FALSE)'

       common_setup "$envname" "$workdir"

        # Start JupyterLab
        jupyter lab --allow-root --ip '0.0.0.0' --port '8787' --NotebookApp.token='' --NotebookApp.notebook_dir="$workdir" --no-browser
    fi
}
