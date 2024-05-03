# change ownership of authorized_keys file in SSH directory
# if we don't do this, public key authentication will fail silently
chown root:root ~/.ssh/authorized_keys

# start SSH server
service ssh start

# run original entrypoint script
/bin/sh -c /app/run_app.sh