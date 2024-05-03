FROM mageai/mageai:latest
# value that is set here is the default value, can be overwritten by docker-compose.yml
ARG USER_CODE_PATH=/home/src/my_mage_prj

# Install OpenSSH server
RUN apt-get update && \
  apt-get install -y openssh-server && \
  apt-get clean

# CMD of original mage image has a run_app.sh script that executes /app/run_app.sh
# we need to do some additional setup related to SSH as well, hence we use a custom entrypoint
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/bin/sh", "-c", "/app/entrypoint.sh"]