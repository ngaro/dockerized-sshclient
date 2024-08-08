# Docker Base Images with OpenSSH Client

These are base images from different distros with an OpenSSH __CLIENT__ added.

## Use Case
These images are designed for one specific use case: accessing systems with SSH servers that frequently change their host keys (e.g., a system with a fixed IP that you often reinstall for testing). 

Using the SSH client on my host system would require modifying my `~/.ssh/known_hosts`, which I prefer to avoid. Instead, these images create a temporary `known_hosts` file each time.

## Usage
You can use the images with the following command:

```bash
docker run -it --rm -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro garo/openssh-client ssh user@server
```

## Available Images
The images are named `garo/openssh-client:tag-of-the-distro` and are available for the amd64 and arm64 architectures.

| Distro       | Version | Tag(s)
| ------------ | ------- | -------------- |
| Alpine       |  3.20.2 | `alpine`, `latest` |
| Kali         |  2024.2 | `kali`         |
| Ubuntu       |  24.04  | `ubuntu`       |
| OpenSSH-only |     9.8 | `empty`, `dev` |

Extra info:
- The `empty` image will become a extremely minimal image with a empty `/root/.ssh` directory and the OpenSSH client at `/ssh`. __No__ other files or directories will be present.<br>
_Note that this image is still in __heavy__ development and will certainly __not__ work yet._
- The Alpine also has the tag `latest`. This means that if you use `garo/openssh-client` without tag you'll get Alpine

## Contributing
- Bugfixes and Dockerfile's for new distributions are always welcome. Submit all pull requests to the `dev` branch.
- If you create a Dockerfile ensure that the file name is `Dockerfile.distroname` and that they are the base images of that distro + the OpenSSH client. Try to avoid extra packages as much as you can.
- Don't submit bugfixes for the `empty` image just yet. I want to work on that one on my own for now.<br>_Once I'll start accepting PR's for `empty` i will remove this message_
