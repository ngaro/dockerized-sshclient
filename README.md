# Docker Base Images with OpenSSH Client

These are base images from different distros with an OpenSSH __CLIENT__ added.

## Use Case
These images are designed for one specific use case: accessing systems with SSH servers that frequently change their host keys (e.g., a system with a fixed IP that you often reinstall for testing). 

Using the SSH client on my host system would require modifying my `~/.ssh/known_hosts`, which I prefer to avoid. Instead, these images create a temporary `known_hosts` file each time.

## Usage
You can use the images with the following command:

```bash
docker run -it --rm -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro garo/openssh-client ssh user@server

## Available Images
Every branch in this repo is for a different distribution. The images are named `garo/openssh-client:branchname` and are available for amd64 and arm64

Only 1 image is available right now: `garo/openssh-client:ubuntu` _(also available as `garo/openssh-client`)_

## Contributing
- If you see a problem that you can fix, please submit a pull request to the relevant branch.
- To add another distro, submit a pull request to the `main` branch with the new `Dockerfile`. _Ensure you use base images of the latest stable version of that distro._
