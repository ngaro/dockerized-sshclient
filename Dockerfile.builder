FROM alpine
WORKDIR /root
RUN apk add --no-cache curl gcc make perl linux-headers musl-dev autoconf automake
COPY ./build-static-ssh.sh .
RUN ./build-static-ssh.sh
COPY dont-use-builder.sh .
ENTRYPOINT ["/root/dont-use-builder.sh"]
