# mods by mraj start

GET_PORT='HOST_IP=$(wget -qO- http://ipecho.net/plain) ; 
          PORT_NUM=$(for port in {8901..8920}; do ss -an | grep -q :$port || { echo $port; break; }; done) ; 
	            echo -e "*****************\n$HOST_IP:$PORT_NUM\n*****************"'

MOUNTDIR=/mnt/disks/$(id -un)
RSTUDIO_PATH=$MOUNTDIR/rstudio
RENV_CACHE_PATH=$MOUNTDIR/renvcache
JUPYTER_PATH=$MOUNTDIR/jupyter
WORKDIR_PATH=$MOUNTDIR/workdir
MOUNTSFILE="$HOME/.config/misc/mounts"
CON_STAT_FILE="$HOME/.config/misc/container"


formatdisk(){

  # ensure at least one argument
  if [ $# -eq 0 ]; then
    echo "no disk name provided"
    echo "usage: formatdisk <disk_name>"
    return 1
  fi
  DISK_NAME=$1

	DISK_ID=$(ls -l /dev/disk/by-id/google-* | grep "$DISK_NAME" | sed 's/.*\///')

  if [ ${#DISK_ID} -gt 0 ]; then
    echo "detected $DISK_NAME at $DISK_ID"
    sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/$DISK_ID
    # error check
    if [ $? -ne 0 ]; then
      echo "error while formatting $DISK_NAME at $DISK_ID"
      return 1
    fi
    echo "formatted $DISK_NAME at $DISK_ID"
  else
    echo "no disk detected with name: $DISK_NAME"
  fi

}

# read from mounts file and mount all
remount(){

  # MOUNTSFILE="$HOME/.config/misc/mounts"
  # if MOUNTSFILE exists, mount all disks in MOUNTSFILE
  if [ -f $MOUNTSFILE ]; then
    echo "mounting from $MOUNTSFILE"
    while read line; do
      DISK_NAME=$(echo $line | awk '{print $1}')
      MOUNTDIR=$(echo $line | awk '{print $2}')
      echo mounting $DISK_NAME at $MOUNTDIR
      mountdisk $DISK_NAME
    done < $MOUNTSFILE
  else
    echo "no mounts file found"
  fi

}


# retrive params
getparams(){

	 # options handling start
	 local options=$(getopt -o "i:m:v:" --long "image:,memory:,volumes:" -- "$@")
	if [ $? -ne 0 ]; then
		echo "Error parsing options." >&2
		return 1
	fi

	eval set -- "$options"

  local memory=16g
  local volumes=""
  local image=""

	while true; do
		case "$1" in
			-m|--memory)
				memory="$2"
				shift 2
				;;
			-i|--image)
				image="$2"
				shift 2
				;;
			-v|--volumes)
				volumes="$2"
				shift 2
				;;
			--)
				shift
				break
				;;
			*)
				echo "Unexpected option: $1" >&2
				return 1
				;;
		esac
	done

  # important
	echo "$memory&$volumes&$image" 

}

# mounts personal dir if needed and creates basic subdirs
domount(){

  df -h | grep "$MOUNTDIR"
  # check if personal drive is mounted at MOUNTDIR
  if [ $? -eq 0 ]; then
    echo "mount at $MOUNTDIR detected"
  else
    echo "no mount at $MOUNTDIR detected. checking mountfile."
    MOUNTSFILE="$HOME/.config/misc/mounts"
    if [[ $(wc -l < $MOUNTSFILE) -gt 0 ]]; then
      echo "loading disk info from mountfile"
      remount
    else
      echo "mountfile is empty"
      echo "please mount a personal disk first using: mountdisk <disk-name>"
      return 1
    fi
  fi

  mkdir -p $RSTUDIO_PATH $RENV_CACHE_PATH $JUPYTER_PATH
}

# builds base image and user image if any doesn't already exist
buildimage(){
    
    local BASE_IMAGE=$1
    local USER_IMAGE=$2
    local IDE=$3

    echo $BASE_IMAGE $USER_IMAGE

    # check if user image exists
    podman image exists $USER_IMAGE
    if [ $? -eq 0 ]; then
      echo "image $USER_IMAGE exists"
      return 0
    fi

    # check if BASE_IMAGE:latest exists
    podman image exists $BASE_IMAGE:latest

    if [ $? -eq 0 ]; then
      echo "image $BASE_IMAGE:latest exists"
    else
      echo "image $BASE_IMAGE:latest does not exist. trying to retrive image.."
      # check if /mnt/disks/common/images/BASE_IMAGE.tar exists
      if [ -f /mnt/disks/common/images/$BASE_IMAGE.tar ]; then
        echo "image $BASE_IMAGE.tar exists. loading image.."
        podman load -i /mnt/disks/common/images/$BASE_IMAGE.tar
        # check if image loaded successfully
        if [ $? -ne 0 ]; then
          echo "error while loading image $BASE_IMAGE"
          return 1
        fi
      else
        echo "image $BASE_IMAGE.tar does not exist. please build the image first."
        return 1
      fi
    fi


    # now build user image; already established user img no exist
    rm -rf /var/tmp/$(whoami)/macosko-compute 
    git clone https://github.com/mukundraj/macosko-compute /var/tmp/$(whoami)/macosko-compute
    echo "building user image $USER_IMAGE"

    podman build --build-arg base_image_name=$BASE_IMAGE:latest --build-arg USER=$USER -t $USER_IMAGE -f /var/tmp/$(whoami)/macosko-compute/src/$IDE/Dockerfile

    podman image exists $USER_IMAGE
    if [ $? -ne 0 ]; then
      echo "error while building image $USER_IMAGE"
      return 1
    fi
    echo "$USER_IMAGE image built"

}

gethostport(){

 local HOST_IP=$(wget -qO- http://ipecho.net/plain) ; 
 local PORT_NUM=$(for port in {8901..8920}; do ss -an | grep -q :$port || { echo $port; break; }; done) ; 
 # echo -e "*****************\n$HOST_IP:$PORT_NUM\n*****************"'
 echo "$HOST_IP:$PORT_NUM"

}

startcontainer(){


  local IMAGE_NAME=$1
  local MEMORY=$2
  local VOLS=$3

  # replace + by space in VOLS
  VOLS=${VOLS//+/ }

  echo 'vols' $VOLS

	local CONTAINER_NAME=$IMAGE_NAME

  echo "startcontainer: name:${IMAGE_NAME} memory:$MEMORY"

	podman container exists $CONTAINER_NAME
  if [ $? -eq 0 ]; then
    echo "container $CONTAINER_NAME exists"
  else

    hostport=$(gethostport)
    IFS=":" read -r HOST_IP PORT_NUM <<< $hostport

    podman run --memory=$MEMORY --name $CONTAINER_NAME -tid --rm -e PASSWORD=$USER -p $PORT_NUM:8787 $VOLS $IMAGE_NAME

    podman ps | grep $CONTAINER_NAME

    if [ $? -eq 1 ]; then
      echo "error. container not created"
      return 1
    else
      echo "container $CONTAINER_NAME created"
      writestate
    fi
  fi
}

# remove stopped containers from CON_STAT_FILE
# for cases where jupyter is stopped externally
sync-con-stat-file(){
  
  # get list of running container names
  local RUNNING_CONTAINERS=$(podman ps | grep -v CONTAINER | awk '{print $NF}')

  # get list of containers in CON_STAT_FILE_FILE
  local CONTAINERS_IN_FILE=$(cat $CON_STAT_FILE | awk '{print $1}')

  # get list of container not running using conn tool
  local STOPPED_CONTAINERS=$(comm -23 <(printf "%s\n" "${CONTAINERS_IN_FILE[@]}" | sort) <(printf "%s\n" "${RUNNING_CONTAINERS[@]}" | sort))

  # remove lines containing STOPPED_CONTAINERS from CON_STAT_FILE
  for container in $STOPPED_CONTAINERS; do
    echo "removing $container from $CON_STAT_FILE"
    sed -i "/$container/d" $CON_STAT_FILE
  done

  echo "synced $CON_STAT_FILE"
}

# stop jupyter container
# usage: stop-jupyter-container <container_name>
stop-jupyter-container(){

  local container_name=$1

  /usr/bin/expect -c "
  set timeout 4
  spawn podman attach $container_name
  sleep 1
  send \"\\003\"
  expect \"Shut down this\"
  sleep 1
  send \"y\\n\"
  expect eof
  "
}

# stop all containers
all-stop(){
  
  local RUNNING_CONTAINERS=$(podman ps | grep -v CONTAINER | awk '{print $NF}')

  # stop each container based on whether rstudio or jupyter
  for container in $RUNNING_CONTAINERS; do
    echo "stopping $container"
    if [[ $container == *"rstudio"* ]]; then
      stop rstudio $container
    elif [[ $container == *"jupyter"* ]]; then
      stop jupyter $container
    else
      echo "unknown container type. skipping $container"
    fi
  done
}

writestate(){
      # write CONTAINER_NAME HOST_IP PORT_NUM to CON_STAT_FILE. Overwrite file if exists.
    if [ -f $CON_STAT_FILE ]; then
      echo "overwriting $CON_STAT_FILE"
      echo "$CONTAINER_NAME $HOST_IP $PORT_NUM" >> $CON_STAT_FILE
    else
      echo "creating $CON_STAT_FILE"
      mkdir -p $(dirname $CON_STAT_FILE)
      echo "$CONTAINER_NAME $HOST_IP $PORT_NUM" > $CON_STAT_FILE

    fi


}

# shows hostip and portnum from CON_STAT_FILE
showinfo(){

    CONTAINER_NAME=$1

    # read HOST_IP and PORT_NUM from CON_STAT_FILE
    if [ -f $CON_STAT_FILE ]; then
      echo "loading container info from $CON_STAT_FILE"
      HOST_IP=$(cat $CON_STAT_FILE | grep $CONTAINER_NAME | awk '{print $2}')
      PORT_NUM=$(cat $CON_STAT_FILE | grep $CONTAINER_NAME | awk '{print $3}')
    else
      echo "container config file not found. please start the container again."
      return 1
    fi

		echo "*************************************************"
		printf "access $CONTAINER_NAME at $HOST_IP:$PORT_NUM\n";
		echo "*************************************************"

}

# starts container; mounts volumes; determine port; write state; showinfo
start(){

  params=$(getparams $@)

  IFS="&" read -r memory volumes image <<< "$params"

  echo startparams: $memory $volumes $image

  sync-con-stat-file

  # check if $image provided and return if not provided
  if [ -z "$image" ]; then
    echo "no image provided. Please provide name of image to run."
    return 1
  fi

  # mount personal disk
  domount

  # start container and write state if container created
  startcontainer $image $memory $volumes
  # error check
  if [ $? -ne 0 ]; then
    echo "error while starting container $image"
    return 1
  fi
  
	local CONTAINER_NAME=$image
  # read state and show connection info
  showinfo $CONTAINER_NAME
}

rstudio(){

  params=$(getparams $@)
  IFS="&" read -r memory volumes_discard image <<< "$params"

  # check if $image has been set
  if [ -z "$image" ]; then
    echo "no image specified. using std image as base image"
    image=std
  fi

  # identify BASE_IMAGE_PATH
  local BASE_IMAGE=""
  local VOLS=""
  case $image in
    basic)
      BASE_IMAGE=rstudio-basic;
      VOLS="-v+$WORKDIR_PATH:/workdir:rw+-v+usr_volume:/usr+-v+$RENV_CACHE_PATH:/root/.cache:rw+-v+$RSTUDIO_PATH:/rstudio:rw" 
      ;;
    std)
      BASE_IMAGE=rstudio-std;
      VOLS="-v+$WORKDIR_PATH:/workdir:rw"
      ;;
    *)
      echo "invalid image name"
      return 1
      ;;
  esac

  
  # build user image to be run ie ${BASE_IMAGE}_$USER
  local USER_IMAGE="${BASE_IMAGE}-$USER"
  echo "base_image:${BASE_IMAGE} user_image:${USER_IMAGE}"
  buildimage ${BASE_IMAGE} $USER_IMAGE "rstudio"
  # check for error
  if [ $? -ne 0 ]; then
    echo "error while building image $USER_IMAGE"
    return 1
  fi

  # pass all args to start and additionally pass image
  start "$@ -i $USER_IMAGE -v ${VOLS}"
}

jupyter(){

  params=$(getparams $@)
  IFS="&" read -r memory volumes_discard image <<< "$params"

  # check if $image has been set
  if [ -z "$image" ]; then
    echo "no image specified. using std image as base image"
    image=std
  fi

  # identify BASE_IMAGE_PATH
  local BASE_IMAGE=""
  local VOLS=""
  case $image in
    basic)
      BASE_IMAGE=jupyter-basic;
      # VOLS="-v+$WORKDIR_PATH:/workdir:rw+" 
      VOLS="-v+$WORKDIR_PATH:/workdir:rw+-v+micromamba:/root/micromamba:rw"+-v+"opt:/opt:rw"
      ;;
    std)
      BASE_IMAGE=jupyter-std;
      VOLS="-v+$WORKDIR_PATH:/workdir:rw+" 
      ;;
    *)
      echo "invalid image name"
      return 1
      ;;
  esac

  
  # build user image to be run ie ${BASE_IMAGE}_$USER
  local USER_IMAGE="${BASE_IMAGE}-$USER"
  echo "base_image:${BASE_IMAGE} user_image:${USER_IMAGE}"
  buildimage ${BASE_IMAGE} $USER_IMAGE "jupyter"
  # check for error
  if [ $? -ne 0 ]; then
    echo "error while building image $USER_IMAGE"
    return 1
  fi

  # pass all args to start and additionally pass image
  start "$@ -i $USER_IMAGE -v ${VOLS}"

}



# stops specified container
stop(){

  IDE=$1
  CONTAINER_NAME=$2

	podman ps | grep $CONTAINER_NAME
	if [ $? -eq 1 ]; then
		echo "container $CONTAINER_NAME is not running";
	else
    # if IDE is jupyter use stop-jupyter-container
    if [ $IDE == "jupyter" ]; then
      stop-jupyter-container $CONTAINER_NAME
    else
      podman stop $CONTAINER_NAME	
    fi
    
		
		podman ps | grep $CONTAINER_NAME
		if [ $? -eq  1 ]; then
			echo container $CONTAINER_NAME stopped
		else
			echo error when stopping container $CONTAINER_NAME
		fi
	fi

  # remove entry from CON_STAT_FILE
  if [ -f $CON_STAT_FILE ]; then
    # echo "removing entry from $CON_STAT_FILE"
    sed -i "/$CONTAINER_NAME/d" $CON_STAT_FILE
  else
    echo "container config file not found."
    return 1
  fi

}

# check if container name provide or can be determined from CON_STAT_FILE
handle-stop(){

  IDE=$1
  CONTAINER_NAME=$2

  # check if container name is provided
  if [ -z "$CONTAINER_NAME" ]; then
    echo "no container name provided"
    num_containers=$(podman ps | grep $IDE | wc -l)

    # check if num_containers is zero
    if [ $num_containers -eq 0 ]; then
      echo "no container running"
      return 1
    fi
    # check if num_containers is one
    if [ $num_containers -eq 1 ]; then
      CONTAINER_NAME=$(podman ps | grep $IDE | awk '{print $NF}')
      echo "detected container $CONTAINER_NAME"
      stop $IDE $CONTAINER_NAME
    else
      echo "multiple containers running. please specify container name"
      # print container names
      podman ps | grep $IDE | awk '{print $NF}'
      echo "usage: $IDE-stop <container_name>"
      return 1
    fi

  else
    stop $IDE $CONTAINER_NAME
  fi

}

rstudio-stop(){

	CONTAINER_NAME=$1

  handle-stop rstudio $CONTAINER_NAME
  
}

jupyter-stop(){

	CONTAINER_NAME=$1

  handle-stop jupyter $CONTAINER_NAME
}

mountdisk(){

  # ensure atleast one arg provided
  if [ $# -eq 0 ]; then
    echo "no disk name provided"
    echo "usage: mountdisk <disk_name>"
    return 1
  fi

  # unmount existing disk
  MOUNTSFILE="$HOME/.config/misc/mounts"
  if [[ $(wc -l < $MOUNTSFILE) -gt 0 ]]; then
    # read first line in MOUNTSFILE
    MOUNTED_DISK_NAME=$(head -n 1 $MOUNTSFILE | awk '{print $1}')
    MOUNTED_DISK_PT=$(head -n 1 $MOUNTSFILE | awk '{print $2}')
    
    # check if $1 not equals MOUNTED_DISK_NAME
    if [ "$1" != "$MOUNTED_DISK_NAME" ]; then
      echo "unmounting $MOUNTED_DISK_NAME at $MOUNTED_DISK_PT"
      unmountdisk $MOUNTED_DISK_NAME
      echo "unmounted $MOUNTED_DISK_NAME"
    fi
  fi

	echo mounting drive $1
	DISK_NAME=$1
	DISK_ID=$(ls -l /dev/disk/by-id/google-* | grep "$DISK_NAME" | sed 's/.*\///')
  if [ ${#DISK_ID} -gt 0 ]; then
    echo "detected $DISK_NAME at $DISK_ID"

    # check if disk is already mounted
    MOUNTDIR=$(df -h | grep "/dev/$DISK_ID" | awk '{print $6}')
    if [ ${#MOUNTDIR} -gt 0 ]; then
      echo "disk $DISK_NAME is mounted at $MOUNTDIR"
      return 1
    fi

    MOUNTDIR=/mnt/disks/$(id -un)
    sudo mkdir -p $MOUNTDIR
    f=$MOUNTDIR
    while [[ $f != / ]]; do sudo chmod a+w "$f"; f=$(dirname "$f"); done;
    sudo mount -o discard,defaults /dev/$DISK_ID $MOUNTDIR
    # check for error
    if [ $? -ne 0 ]; then
      echo "error while mounting $DISK_NAME at $MOUNTDIR"
      return 1
    fi
    echo mounted $1 at $MOUNTDIR
    echo setting permissions for $1
    sudo chown -R $(id -u):$(id -g) $MOUNTDIR

    echo 'updating mounts file'
    MOUNTSFILE="$HOME/.config/misc/mounts"
    mkdir -p $(dirname $MOUNTSFILE) && touch $MOUNTSFILE
    # add to mounts file
    if ! grep -q "$DISK_NAME" $MOUNTSFILE; then
      echo "$DISK_NAME $MOUNTDIR" >> $MOUNTSFILE
      echo "added $DISK_NAME to mounts file"
    else
      echo "$DISK_NAME exists in mounts file"
    fi

    echo done
  else
    echo "no disk detected with name: $DISK_NAME"
  fi
}

# differences from mountdisk:
# accepts a mount_pt
# doesn't update mounts file
# doesn't update permissions
mountdiskat(){

  # ensure atleast two arg provided
  if [ $# -lt 2 ]; then
    echo "args disk_name and mount_pt needed"
    echo "usage: mountdiskat <disk_name> <mount_pt>"
    return 1
  fi

	echo mounting drive $1
	DISK_NAME=$1
	DISK_ID=$(ls -l /dev/disk/by-id/google-* | grep "$DISK_NAME" | sed 's/.*\///')
  if [ ${#DISK_ID} -gt 0 ]; then
    echo "detected $DISK_NAME at $DISK_ID"

    # check if disk is already mounted
    MOUNTDIR=$(df -h | grep "/dev/$DISK_ID" | awk '{print $6}')
    if [ ${#MOUNTDIR} -gt 0 ]; then
      echo "disk $DISK_NAME is mounted at $MOUNTDIR"
      return 1
    fi

    MOUNTDIR=$2
    sudo mkdir -p $MOUNTDIR
    f=$MOUNTDIR
    while [[ $f != / ]]; do sudo chmod a+w "$f"; f=$(dirname "$f"); done;
    sudo mount -o discard,defaults /dev/$DISK_ID $MOUNTDIR
    # check for error
    if [ $? -ne 0 ]; then
      echo "error while mounting $DISK_NAME at $MOUNTDIR"
      return 1
    fi
    echo mounted $1 at $MOUNTDIR
    # echo setting permissions for $1
    # sudo chown -R $(id -u):$(id -g) $MOUNTDIR

    # echo 'updating mounts file'
    # MOUNTSFILE="$HOME/.config/misc/mounts"
    # # add to mounts file
    # if ! grep -q "$DISK_NAME" $MOUNTSFILE; then
    #   echo "$DISK_NAME $MOUNTDIR" >> $MOUNTSFILE
    #   echo "added $DISK_NAME to mounts file"
    # else
    #   echo "$DISK_NAME exists in mounts file"
    # fi

    echo done
  else
    echo "no disk detected with name: $DISK_NAME"
  fi


}

unmountdisk(){

  # ensure atleast one arg is provided
  if [ $# -eq 0 ]; then
    echo "no disk name provided"
    echo "usage: unmountdisk <disk_name>"
    return 1
  fi

	DISK_NAME=$1
  echo unmouting disk $DISK_NAME
	DISK_ID=$(ls -l /dev/disk/by-id/google-* | grep "$DISK_NAME" | sed 's/.*\///')

  if [ ${#DISK_ID} -eq 0 ]; then
    echo "no disk detected with name: $DISK_NAME"
    return 1
  fi

  MOUNTDIR=$(df -h | grep "/dev/$DISK_ID" | awk '{print $6}')

  if [ ${#MOUNTDIR} -gt 0 ]; then

    echo $1 detected at $MOUNTDIR
    echo "unmounting $MOUNTDIR"
	# sudo umount /mnt/disks/user-$(id -un)
    sudo umount $MOUNTDIR
    # check for error
    if [ $? -ne 0 ]; then
      echo "error while unmounting $DISK_NAME at $MOUNTDIR"
      return 1
    fi

    # update mounts file
    echo 'updating mounts file'
    MOUNTSFILE="$HOME/.config/misc/mounts"
    # remove from mounts file
    if grep -q "$DISK_NAME" $MOUNTSFILE; then
      sed -i "/$DISK_NAME/d" $MOUNTSFILE
      echo "removed $DISK_NAME from mounts file"
    else
      echo "$DISK_NAME not found in mounts file"
    fi

    echo done
  else
    echo no mount point detected for $DISK_NAME
    return 1
  fi
}

refreshdisk(){

  # ensure at least one arg
  if [ $# -eq 0 ]; then
    echo "no disk name provided"
    echo "usage: diskrefresh <disk_name>"
    return 1
  fi

	DISK_NAME=$1
  echo refreshing $DISK_NAME
	DISK_ID=$(ls -l /dev/disk/by-id/google-* | grep "$DISK_NAME" | sed 's/.*\///')

  if [ ${#DISK_ID} -eq 0 ]; then
    echo "no disk detected with name: $DISK_NAME"
    return 1
  fi

  sudo resize2fs /dev/$DISK_ID

  # check for error
  if [ $? -ne 0 ]; then
    echo "error while refreshing $DISK_NAME"
    return 1
  fi

  echo done

}

# utility fn to change uid and gid 
changeuid(){

USERNAME=$1
NEW_UID=$2

  # Ensure current user is not USERNAME
  if [ "$(id -u)" -eq "$(id -u "$USERNAME")" ]; then
    echo "Cannot change the UID of the current user."
    exit 1
  fi

  # change the User ID (UID)
  sudo usermod -u "$NEW_UID" "$USERNAME"

  # change the ownership of the user's home directory and its contents to the new UID
  sudo chown -R "$NEW_UID":"$(id -g -n "$USERNAME")" "/home/$USERNAME"

  echo "UID changed to '$NEW_UID' and ownership of home directory updated."

}

export EDITOR=vi

# mods by mraj end
