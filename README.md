# Docker Base Images with OpenSSH Client

These are base images from different distros with an OpenSSH __CLIENT__ added.<br>Also included is a empty image with only the ssh client.

## Use Case
These images are designed for one specific use case: accessing systems with SSH servers that frequently change their host keys (e.g., a system with a fixed IP that you often reinstall for testing). 

Using the SSH client on my host system would require modifying my `~/.ssh/known_hosts`, which I prefer to avoid. Instead, these images create a temporary `known_hosts` file each time.

## Usage
Some examples:
```bash
# A simple connection to "server" as "user":
docker run -it --rm garo/openssh-client ssh user@server

# But this time you want to be able to login with your keys instead of password:
docker run -it --rm -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro garo/openssh-client ssh user@server

# And now you also want some compression on the connection
docker run -it --rm -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro garo/openssh-client ssh -C user@server

# Using the Ubuntu based image
docker run -it --rm -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro garo/openssh-client:ubuntu ssh -C user@server

# Going lightweight and using a image only containing ssh. Note the slash in front of ssh here !
docker run -it --rm -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro garo/openssh-client:empty /ssh -C user@server

# Copying a `/home/user/somefile` to the server at `/some/location/`:
docker run -it --rm -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro garo/openssh-client scp /home/user/somefile user@server:/some/location/

#For people that hate typing I strongly recommend this in your ~/.bashrc, ~/.zshrc, ...
alias sshdocker="docker run -it --rm -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro garo/openssh-client ssh"
alias scpdocker="docker run -it --rm -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro garo/openssh-client scp"
```

## Available Images
The images are named `garo/openssh-client:tag-of-the-distro` and are available for the amd64 and arm64 architectures.

| Distro  | Distro Version | OpenSSH Version | All client programs | Tag(s)
| ------- | -------------- | --------------- | ------------------- | -------------------- |
| _None_  |        __/__   |           9.8p1 | No                  | `empty`              |
| Busybox |         1.36.1 |           9.8p1 | No                  | `busybox`            |
| Alpine  |         3.20.2 |           9.7p1 | Yes                 | `alpine`, `latest`   |
| Arch    |     2024.08.04 |           9.8p1 | Yes                 | `arch`, `arch-arm64` |
| Debian  |             12 |           9.2p1 | Yes                 | `debian`             |
| Fedora  |             40 |           9.6p1 | Yes                 | `fedora`             |
| Mageia  |              9 |           9.3p1 | Yes                 | `mageia`             |
| Kali    |         2024.2 |           9.7p1 | Yes                 | `kali`               |
| Ubuntu  |          24.04 |           9.6p1 | Yes                 | `ubuntu`             |

## Notes
- `empty` contains only 2 files:
  - `/ssh` _(The self-compiled OpenSSH client)_
  - `/etc/passwd` with only 1 line: `root:x:0:0:root:/:/ssh` _(ssh needs to know it's user)_
  - __No__ other files or directories are present.<br>This implies thay you will have to __launch ssh as `/ssh` instead of `ssh` in `empty`__
- `busybox` contains the same self-compiled OpenSSH client.
- Arch Linux has no official base image for arm64. `arch-arm64` is based on an unofficial image and has a different tag to make it clear.
- There is also a `builder` that was used to compile OpenSSH for `empty` and `busybox`. It cannot be used directly and should be ignored
- For now consider all images _(certainly `empty` and `busybox`)_ as experimental. Report all issues.


## Contributing
- Bugfixes and Dockerfile's for new distributions are always welcome. Submit all pull requests to the `dev` branch.
- If you create a Dockerfile ensure that the file name is `Dockerfile.distroname` and that they are the base images of that distro + the OpenSSH client. Try to avoid extra packages as much as you can.
