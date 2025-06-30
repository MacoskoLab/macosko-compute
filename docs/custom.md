# using custom container image 

(advanced: before proceeding you'll need to have a custom Dockerfile ready)

## 1. use custom docker image on shared, high memory VM

- log in to VM `highmem1` if not already logged in
- mount personal disk using following command
    ```
    mountdisk <disk-name>
- build and run custom Dockerfile

    Instead of the prebuild rstudio and jupyter lab images, you can launch a
    container built using a custom Dockerfile. Sample commands are below. Run
    the commands from same folder as the Dockerfile and change or add variable values
    if/as needed.

    ```
    IMAGE_NAME=custom-$USER
    CONTAINER_NAME=custom-$USER

    podman build -f Dockerfile -t $IMAGE_NAME .

    MEMORY=160g
    PORT_NUM=$(gethostport|cut -d: -f2)

    podman run --memory=$MEMORY --name $CONTAINER_NAME -tid --rm -e PASSWORD=$USER -p $PORT_NUM:8787 -v /mnt/disks/$USER/workdir:/workdir:rw $IMAGE_NAME
    ```
- connect to container as usual via ```HOSTIP:PORT_NUM```

- save and retrieve image
    
    the following commands are useful to save and retrieve built images:

    - to save image 
    ```
    IMAGE_NAME=custom-$USER
    podman save -o $IMAGE_NAME.tar $IMAGE_NAME:latest
    ```
    - to load image  
    ```
    podman load -i $IMAGE_NAME.tar

    ```
