#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")/.."

lookup_version() {
  export GIT_COMMIT_HASH="$(git show -s --format=%H)"
  export GIT_COMMIT_HYGIENE="$(git diff-index --quiet HEAD && echo 'clean' || echo 'dirty')"
  export GIT_COMMIT_TIMESTAMP="$(date --date="@$(git show -s --format=%ct)" +'%Y-%m-%dT%H:%M:%S%:z')"
  export GIT_COMMIT_VERSION=\
"$(date --utc --date="@$(git show -s --format=%ct)" +'%Y%m%d.%H%M%S').$(git show -s --format=%H | cut -c 1-10)"\
"$(git diff-index --quiet HEAD && echo '' || echo '-dirty')"
  env | grep GIT_COMMIT_ | sort -n
}

export APP_NAME=openjdk-jdk8u
export IMAGE_NAME="docker-prod.registry.kroger.com/search/${APP_NAME:?}"
lookup_version >/dev/null

docker build --rm \
  --build-arg ARTIFACT_VERSION="${GIT_COMMIT_VERSION:?}" \
  --tag "${IMAGE_NAME}:${GIT_COMMIT_VERSION:?}" \
  docker/ &&
  # If the build succeeds, tag it as "local"
  docker tag "${IMAGE_NAME}:${GIT_COMMIT_VERSION:?}" "${IMAGE_NAME}:local" &&
  # And run the build in the container
  docker run --rm --net=host -v "$(pwd)":/openjdk-jdk8u docker-prod.registry.kroger.com/search/openjdk-jdk8u:local \
    bash -c '                                                                             \
        cd /opt                                                                        && \
        tar -xzf jdk-7u80-linux-x64.tar.gz                                             && \
        tar -xzf binutils-2.23.2.tar.gz                                                && \
        cd /openjdk-jdk8u                                                              && \
        export PATH=/opt/jdk1.7.0_80/bin:"$PATH"                                       && \
        bash ./configure                                                               && \
        make clean                                                                     && \
        make all                                                                       && \
        cd hotspot/src/share/tools/hsdis                                               && \
        # ---------------------------------------------------------------------------     \
        # First, we have to run make and let it fail.  Then, we have to touch the         \
        # bfd.info file and run make again.  See hotspot/src/share/tools/hsdis/README.    \
        # ---------------------------------------------------------------------------     \
        make BINUTILS=/opt/binutils-2.23.2 all64                                       || \
        touch /opt/binutils-2.23.2/bfd/doc/bfd.info                                    && \
        make BINUTILS=/opt/binutils-2.23.2 all64                                          \
        '
