#! /bin/bash

# Loop through arguments, two at a time for key and value
while [[ $# > 0 ]]
do
    key="$1"

    case $key in
        -t|--docker-tag-name)
            DOCKER_TAG_NAME="$2"
            shift # past argument
            ;;
        -r|--docker-tag-name)
            REMOTE_TAG_NAME="$2"
            shift # past argument
            ;;
        -v|--verbose)
            VERBOSE=true
            ;;
        *)
            usage
            exit 2
        ;;
    esac
    shift # past argument or value
done

# Push only if it's not a pull request
if [ -z "$TRAVIS_PULL_REQUEST" ] || [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
  # Push only if we're testing the master branch - fixed
  if [ "$TRAVIS_BRANCH" == "master" ]; then
  
    # This is needed to login on AWS and push the image on ECR
    # Change it accordingly to your docker repo
    pip install --user awscli
    export PATH=$PATH:$HOME/.local/bin
    eval $(aws ecr get-login --region $AWS_DEFAULT_REGION)
    
    # Build and push
    docker build -t $DOCKER_TAG_NAME .
    echo "Pushing $DOCKER_TAG_NAME:latest"
    docker tag $DOCKER_TAG_NAME:latest "$REMOTE_TAG_NAME:latest"
    docker push "$DOCKER_TAG_NAME:latest"
    echo "Pushed $DOCKER_TAG_NAME:latest"
  else
    echo "Skipping deploy because branch is not 'master'"
  fi
else
  echo "Skipping deploy because it's a pull request"
fi
