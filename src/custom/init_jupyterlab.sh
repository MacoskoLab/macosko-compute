init_jupyterlab() {
    # Check if the 'jupyterlab' environment exists
    if micromamba env list | grep -q "jupyterlab"; then
        echo "JupyterLab environment found. Activating and starting JupyterLab..."
        micromamba activate jupyterlab
        jupyter lab --allow-root --ip '0.0.0.0' --port '8787' --NotebookApp.token='' --NotebookApp.notebook_dir='/workdir' --no-browser
    else
        echo "JupyterLab environment not found. Creating and starting JupyterLab..."
        # Create the environment



       micromamba create -n jupyterlab -y python=3.11.2 jupyterlab pandas -c conda-forge

       # set password 
       expect -c '
       spawn bash -lc "micromamba run -n jupyterlab jupyter lab password"
       expect "Enter password:"
       send "$env(USER)\r"
       expect "Verify password:"
       send "$env(USER)\r"
       expect eof
       '
       # expect -c 'spawn bash -lc "micromamba run -n jupyterlab jupyter lab password"; expect "Enter password:"; send "$USER\r"; expect "Verify password:"; send "$USER\r"; expect eof'

       micromamba run -n jupyterlab jupyter lab --generate-config && echo -e 'c.ServerApp.terminals_enabled = True\nc.FileContentsManager.delete_to_trash = False' >> /root/.jupyter/jupyter_lab_config.py

        # Install the R kernel for JupyterLab
        micromamba run -n jupyterlab R -e 'IRkernel::installspec(user = FALSE)'

        # Activate the new environment
        micromamba activate jupyterlab


        # Start JupyterLab
        jupyter lab --allow-root --ip '0.0.0.0' --port '8787' --NotebookApp.token='' --NotebookApp.notebook_dir='/workdir' --no-browser
    fi
}
