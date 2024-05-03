# mage.ai with SSH + Git repo sync
A custom Docker image extending the official [mage.ai Docker Image](https://hub.docker.com/r/mageai/mageai), adding SSH capabilities. This repo also demonstrates how to setup a Git repository with the mage pipeline code and config in the mage container and sync the code between the container and a remote Git repository.

This setup allows you to connect to a running mage instance via SSH. If you use VS Code, you can even use the [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension to have almost the same coding experience as if you were coding on your local machine.

You can also interact with Git via the command line (e.g. to push/pull changes), bypassing the (in my experience quite buggy and clunky) Git integration in mage's browser UI.

## Setup steps
Create a `.env` file in the root of your project with suitable values for all variables mentioned in the `.env.example` file.

Create an `authorized_keys` file in the `mage` folder with public SSH keys that should be accepted for SSH connections to the container.

If you want to connect from your local machine, make sure you have created a public key with a command like
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Once you have your public key, just copy it. Usually, the default SSH key can be found at `~/.ssh/id_rsa.pub`. You can print it by running
```bash
cat ~/.ssh/id_rsa.pub
```

Then, copy the key and paste it into the `authorized_keys` file.

## Running the container
Just run `docker-compose up` to start the container. The first time you run this command, it will build the image, which may take a while. Subsequent runs will be faster.

You should see logs like
```
mage-ssh-mage-1  | Starting OpenBSD Secure Shell server: sshd.
mage-ssh-mage-1  | Starting project at /home/src/my_mage_prj, project type standalone
```
which tells you that the SSH server is running and the mage project has been started :)

If you get an error like
```
mage-ssh-mage-1  | ERROR:mage_ai.server.server:Failed to sync data from git repo: ...
```
you have probably messed up something in the configuration for the Git repository. Check the environment variables starting with `MAGE_PRJ_CODE_GIT_` in the `.env` file.

## Connecting to the running container via SSH
At this point, you should be able to connect to the container via SSH.

### Connect to machine
On the host machine, you can run:
```bash
ssh -p 2222 root@localhost
```

To make connecting to the container more convenient, add the following to your `~/.ssh/config` file:
```ssh-config
Host mage-localhost
    HostName localhost
    Port 2222
    User root
    IdentityFile ~/.ssh/id_rsa
```

If you want to connect to the container from a different machine, you can replace `localhost` with the IP address of the machine running the container. Of course, port 2222 needs to be available from the outside then.

### Access the mage project and git
The mage project should be located at `/home/src/my_mage_prj`. Just `cd` into that directory to access the project files (or select that folder in the UI when connecting via VS Code's Remote SSH extension).

## Caveats/Issues

### SSH error after rebuild
After rebuilding the container (e.g. when you update to a new version of mage), you may get an error somewhat like this when trying to connect via SSH:
```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
SHA256:....
Please contact your system administrator.
Add correct host key in ... to get rid of this message.
Offending ECDSA key in ...
Host key for [...]:2222 has changed and you have requested strict checking.
Host key verification failed.
```

To fix this, you need to remove the offending key from your `~/.ssh/known_hosts` file. The error message will tell you which line to remove.

### Example code generation
It seems like per default the `mage` image always creates example code (pipelines, pipeline blocks, configs, etc.). To get rid of that just run `git stash -a` after the container boots up.