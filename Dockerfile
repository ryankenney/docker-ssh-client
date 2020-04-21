FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y \
      # Used to install fixuid
      curl \
      # Just handy
      less vim \
      # SSH
      openssh-client \
      # Tab-completion
      bash-completion && \
    # Wipe cache
    rm -rf /var/lib/apt/lists/* && \
    # Load bash-completions into terminal
    echo "source /usr/share/bash-completion/bash_completion" >> /etc/bash.bashrc

# Create a non-root user and group
#
# The UID/GID is overridden by fixuid at runtime, so we set the default
# value to unlikely values 1099:1099, ensuring that we'll notice any
# problems for developers using the container, whether they have the
# first uid/gid (1000:1000), or later values (1001:1001, 1002:1002...).
# The only reason the UID/GID inside the container matters is that
# the user writes back to the volume mounted from the host.
RUN groupadd -r user -g 1099 && \
    useradd -u 1099 -g user -m user
#    install -o user -g user -m 0700 -d /home/user/.ssh

# Load "fixuid" as the primary ENTRYPOINT. This allows us to select user uid/gid values
# at runtime, which is necessary if we want to allow the container to interact with a host
# volume using the uid/gid of the host user.
RUN USER=user && \
    GROUP=user && \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.3/fixuid-0.3-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml
ENTRYPOINT ["fixuid"]

USER user

CMD ["/bin/bash"]
