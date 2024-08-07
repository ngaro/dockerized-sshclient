FROM alpine AS builder
WORKDIR /root
RUN apk add --no-cache gcc musl-dev
COPY ssh.c /root
RUN gcc -static -o ssh ssh.c

FROM scratch
COPY --from=builder /root/ssh /ssh
CMD ["/ssh"]
