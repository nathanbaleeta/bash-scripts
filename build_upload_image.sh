#!/bin/bash

# https://www.redhat.com/en/blog/arguments-options-bash-scripts
# https://medium.com/@max.kombarov/automating-bash-script-installation-and-docker-build-and-verification-in-ci-cd-by-qa-7210f536daf8
# https://github.com/nathanbaleeta/k8s-docker-images/tree/main/zookeeper

############################################################
# Help                                                     #
############################################################
help()
{
   # Display Help
   echo "Build docker image for Magasin Zookeeper cluster coordinator"
   echo
   echo "Syntax: scriptTemplate [-r|h|t|v]"
   echo "options:"
   echo "r     Specify container registry."
   echo "h     Print this Help."
   echo "t     Specify docker image tag."
   echo "v     Specify docker image version."
   echo
   echo "For example:"
   echo 
   echo "build_upload_image.sh -r nathanacrdev.azurecr.io -t zookeeper -v 3.7.2"
}

############################################################
# Main program                                             #
############################################################

# Set variables
CONTAINER_REGISTRY="container"
IMAGE_NAME="tag"
IMAGE_VERSION="version"

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
while getopts ":h:r:t:v:" option; do
   case $option in
      h) # display Help
         help
         exit;;
      r) # Enter container registry 
         CONTAINER_REGISTRY=$OPTARG;;
      t) # Enter container tag 
         IMAGE_NAME=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

# Set the variables
echo "Container registry -  $CONTAINER_REGISTRY!"
echo "Image tag -  $IMAGE_NAME!"
echo "Image version -  $IMAGE_VERSION!"

# Build the Docker image
# docker build -t $IMAGE_NAME -f $DOCKERFILE_PATH .
# docker buildx build --platform linux/amd64 -t nathanacrdev.azurecr.io/zookeeper:3.7.2 --push .
docker buildx build --platform linux/amd64 -t nbaleeta/zookeeper:3.9.3 --push .
