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

| Distro | Version | Tag(s)
| ------ | ------- | -------------- |
| Alpine |  3.20.2 | `alpine`, `latest` |
| Kali   |  2024.2 | `kali`         |
| Ubuntu |  24.04  | `ubuntu`       |

Note that Alpine also has the tag `latest`. This means that if you use `garo/openssh-client` without tag you'll get Alpine

## Contributing
- If you see a problem that you can fix, please submit a pull request to the relevant branch.<br>_(There is a separate branch for every distro)_
- To add another distro, submit a pull request to the `main` branch with the new `Dockerfile`.<br>_Ensure you use base images of the latest stable version of that distro._
