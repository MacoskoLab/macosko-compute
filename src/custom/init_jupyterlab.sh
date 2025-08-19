
common_setup(){
       local envname="$1"
       # set password 
       expect -c "
       spawn bash -lc \"micromamba run -n $envname jupyter lab password\"
       expect \"Enter password:\"
       send \"\$env(USER)\\r\"
       expect \"Verify password:\"
       send \"\$env(USER)\\r\"
       expect eof
       "

       micromamba run -n "$envname" jupyter lab --generate-config && echo -e 'c.ServerApp.terminals_enabled = True\nc.FileContentsManager.delete_to_trash = False' >> /root/.jupyter/jupyter_lab_config.py

        # Install the R kernel for JupyterLab
        micromamba run -n "$envname" R -e 'IRkernel::installspec(user = FALSE)'


}

init_jupyterlab() {
    local envname="${1:-jupyterlab}"
    # Check if the environment exists
    if micromamba env list | grep -q "$envname"; then
        echo "$envname environment found. Activating and starting JupyterLab..."
        micromamba activate "$envname"

        common_setup "$envname"

        jupyter lab --allow-root --ip '0.0.0.0' --port '8787' --NotebookApp.token='' --NotebookApp.notebook_dir='/workdir' --no-browser
    else
        echo "$envname environment not found. Creating and starting JupyterLab..."
        # Create the environment

       micromamba create -n "$envname" -y python=3.11.2 jupyterlab pandas -c conda-forge

       # Activate the new environment
       micromamba activate "$envname"

       common_setup "$envname"

        # Start JupyterLab
        jupyter lab --allow-root --ip '0.0.0.0' --port '8787' --NotebookApp.token='' --NotebookApp.notebook_dir='/workdir' --no-browser
    fi
}
