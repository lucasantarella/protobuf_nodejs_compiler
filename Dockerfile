FROM debian:stretch

# Install deps
RUN apt-get update -y && apt-get install -y \
    curl \
    unzip \
    git \
    build-essential \
    autoconf \
    dh-autoreconf \
    automake

WORKDIR /tmp/

RUN git clone -b $(curl -L https://grpc.io/release) https://github.com/grpc/grpc && \
    cd grpc && \
    git submodule update --init

# Make plugins
RUN cd /tmp/grpc && \
    make && \
    make install && \
    make grpc_node_plugin && \
    mv /tmp/grpc/bins/opt/grpc_node_plugin /usr/local/bin && \
    rm -r /tmp/*

# Get binaries
RUN curl -L -o /tmp/protoc.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.9.1/protoc-3.9.1-linux-x86_64.zip && \
    unzip /tmp/protoc.zip bin/protoc -d /tmp/ &&  \
    mv /tmp/bin/protoc /usr/local/bin/protoc && \
    chmod a+x /usr/local/bin/protoc && \
    rm -r /tmp/bin && \
    rm /tmp/protoc.zip


# Get protobuf includes
RUN curl -L -o /tmp/protobuf.tar.gz https://github.com/protocolbuffers/protobuf/releases/download/v3.9.1/protobuf-all-3.9.1.tar.gz && \
    tar -xvf /tmp/protobuf.tar.gz protobuf-3.9.1/src/google &&  \
    mv /tmp/protobuf-3.9.1/src/google /usr/include/google && \
    rm -r /tmp/protobuf-3.9.1 && \
    rm /tmp/protobuf.tar.gz

FROM node:10.12.0

RUN npm i -g ts-protoc-gen --unsafe-perm
RUN npm i -g grpc-tools --unsafe-perm

COPY --from=0 /usr/local/bin/protoc /usr/local/bin/protoc
COPY --from=0 /usr/local/bin/grpc_node_plugin /usr/local/bin/grpc_node_plugin
COPY --from=0 /usr/include/google /usr/include/google
ENV PATH="/usr/include/:${PATH}"

WORKDIR /tmp/

ENTRYPOINT ["grpc_tools_node_protoc", "-I", "/usr/include"]
