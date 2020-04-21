#!/bin/bash

set -ex

sudo docker build -t 127.0.0.1:docker-ssh-client .

sudo docker run \
  `# Use the host's un-sandboxed network` \
  --network host \
  `# Specify the host user's uid/gid so the mounted files have the right permissions` \
  --user "$(id -u):$(id -g)" \
  `# Run interactively` \
  -it \
  `# Mount the ssh configs` \
  -v "$HOME/.ssh/ssh-agent-sandbox:/home/user" \
  -v "$HOME/.ssh/known_hosts:/home/user/.ssh/known_hosts" \
  `# Destroy the container on exit (stateless)` \
  --rm \
  127.0.0.1:docker-ssh-client


