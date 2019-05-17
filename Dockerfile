############################
# STEP 1 build executable binary
############################
FROM golang:alpine AS builder
# Install git.
# Git is required for fetching the dependencies.
RUN apk update && apk add --no-cache git 
#Change the Working Directory
WORKDIR $GOPATH/src/phantom/
#Clone Github Repo
RUN  git clone https://github.com/breakcrypto/phantom.git . &&\
     git checkout -b pivx &&\
     cd cmd
# Fetch dependencies.
# And Compile Binary
RUN cd cmd/phantom &&\
    go get -d -v ./... &&\
    go install -v ./... &&\
    go build -o /go/bin/phantom
    
############################
# STEP 2 build a small image
############################
FROM alpine:edge
# Install SSL Certs
RUN apk add --no-cache ca-certificates
# Copy our static executable.
COPY --from=builder /go/bin/phantom /usr/local/bin/
# Change Working dir
WORKDIR /phantom
VOLUME ["/phantom/coin_config", "/phantom/masternode_config"]
#Run the Phantom Binary
ENTRYPOINT ["/usr/local/bin/phantom","-coin_conf=/phantom/coin_config/coin.conf","-masternode_conf=/phantom/masternode_config/masternode.conf"]
