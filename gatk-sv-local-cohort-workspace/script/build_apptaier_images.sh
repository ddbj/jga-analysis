#!/bin/bash

cat workspace/data/dockers.json | jq 'to_entries | map(select(.key != "name" and .key != "melt_docker")) | .[].value' | xargs -I{} apptainer exec docker://{} echo 'pulled {}'
