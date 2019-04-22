############################
# STEP 1 build executable binary
############################
FROM golang:alpine AS builder
# Install git.
# Git is required for fetching the dependencies.
RUN apk update && apk add --no-cache git 
WORKDIR $GOPATH/src/phantom/
RUN  git clone https://github.com/breakcrypto/phantom.git .
# Fetch dependencies.
# Using go get.
RUN go get -d -v
# Build the binary.
RUN go build -o /go/bin/phantom

############################
# STEP 2 build a small image
############################
FROM alpine:edge
# Install SSL Certs
RUN apk add --no-cache ca-certificates 
WORKDIR /masternodes
# Copy our static executable.
COPY --from=builder /go/bin/phantom /usr/local/bin/
#Run the Phantom Binary
ENTRYPOINT ["/usr/local/bin/phantom","-magicbytes=E4D2411C","-port=1929", "-protocol_number=70209", "-magic_message=ProtonCoin Signed Message:", "-bootstrap_ips=51.15.236.48:1929", "-bootstrap_url=http://explorer.anodoscrypto.com:3001", "-max_connections=10"]
