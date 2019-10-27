FROM node:9.1-debian

RUN apk update && apk add \
    build-base \
    linux-headers \
    make \
    git \
    protobuf \
    protobuf-dev

RUN npm --global install ts-protoc-gen
RUN npm --global install --unsafe-perm grpc-tools
