# Build Stage
FROM ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang curl
RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN ${HOME}/.cargo/bin/rustup default nightly
RUN ${HOME}/.cargo/bin/cargo install -f cargo-fuzz

## Add source code to the build stage.
ADD . /textwrap
WORKDIR /textwrap
RUN ${HOME}/.cargo/bin/cargo build
RUN cd fuzz && ${HOME}/.cargo/bin/cargo fuzz build

# Package Stage
FROM ubuntu:20.04

COPY --from=builder textwrap/fuzz/target/x86_64-unknown-linux-gnu/release/fill_first_fit /
COPY --from=builder textwrap/fuzz/target/x86_64-unknown-linux-gnu/release/fill_optimal_fit /
COPY --from=builder textwrap/fuzz/target/x86_64-unknown-linux-gnu/release/wrap_first_fit /
COPY --from=builder textwrap/fuzz/target/x86_64-unknown-linux-gnu/release/wrap_optimal_fit_usize /
COPY --from=builder textwrap/fuzz/target/x86_64-unknown-linux-gnu/release/wrap_optimal_fit /
