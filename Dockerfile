FROM ubuntu:latest as builder

RUN apt-get update && apt-get install build-essential git gperf libgmp-dev cmake bison curl flex gcc-multilib linux-libc-dev libboost-all-dev libtinfo-dev ninja-build python3-setuptools unzip wget python3-pip openjdk-8-jre -y

RUN git clone https://github.com/esbmc/esbmc

RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz

RUN tar xJf clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz && mv clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-20.04 clang11

RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.8.9/z3-4.8.9-x64-ubuntu-16.04.zip && unzip z3-4.8.9-x64-ubuntu-16.04.zip && mv z3-4.8.9-x64-ubuntu-16.04 z3

RUN mkdir esbmc/build
RUN mkdir esbmc/release

WORKDIR esbmc/build

RUN cmake ..  -GNinja -DBUILD_TESTING=On -DENABLE_REGRESSION=On -DClang_DIR=$PWD/../../clang11 -DLLVM_DIR=$PWD/../../clang11 -DBUILD_STATIC=On -DZ3_DIR=$PWD/../../z3 -DENABLE_SOLIDITY_FRONTEND=On -DCMAKE_INSTALL_PREFIX:PATH=$PWD/../../release
RUN cmake --build . && ninja install

FROM alpine:latest

COPY --from=builder /release/bin/esbmc ./

CMD ["./esbmc","--help"]