
FROM ghcr.io/qno/windows-sdk as winsdk
FROM ubuntu:latest
ENV LANG C.UTF-8

# Create unprivileged user
RUN groupadd -g 1000 build
RUN useradd --create-home --uid 1000 --gid 1000 --shell /bin/bash build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends wget build-essential python3-pip ninja-build g++ gcc git lsb-release software-properties-common gnupg
RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" -- 17
RUN apt-get install -y --no-install-recommends clang-tools-17 && \
    rm -rf /var/lib/apt/lists/*

USER build
WORKDIR /home/build/
RUN pip3 install conan cmake --user
RUN pip3 cache purge
#COPY --from=winsdk --chown=build:build /home/build/WindowsSDK /home/build/WindowsSDK
ENV PATH=".local/bin:${PATH}"
CMD ["/bin/bash"]
