FROM ubuntu:latest

RUN apt-get update -y && apt-get install -y curl nodejs npm clang make build-essential

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
RUN npm install typescript -g
RUN npm install -g dart_js_facade_gen
RUN cargo install just
RUN curl -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.0.5-stable.tar.xz && tar xf flutter.tar.xz && chown -R root:root /flutter

ADD . fluttermint
WORKDIR fluttermint
ENV PATH="$PATH:/flutter/bin"
RUN flutter precache
RUN flutter channel stable
RUN flutter upgrade

RUN just wasm --dev