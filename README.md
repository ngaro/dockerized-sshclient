# Docker base-images with ssh-CLIENTS added
These images are just base images from some distros with a openssh __CLIENT__ added.

For me they only have 1 use-case:<br>Accessing systems with ssh servers that for some reason constantly change their hostkeys.<br>
_(e.g. a system with a fixed IP that you often reinstall for testing things)_

If I would use ssh on the hostsystem I would have to change my `~/.known_hosts` which I don't want.

This is how i use it: `docker run -it --rm -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro garo/openssh-client ssh user@server`
