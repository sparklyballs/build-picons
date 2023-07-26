FROM debian:bookworm-slim

# build args
ARG RELEASE

# add local files
COPY backgrounds.conf /src/


# install packages
RUN \
	apt-get update \
	&& apt-get install \
		--no-install-recommends \
		-y \
		binutils \
		bzip2 \
		ca-certificates \
		curl \
		git \
		gzip \
		imagemagick \
		jq \
		librsvg2-bin \
		pngquant \
# cleanup
	\
	&& rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# set workdir
WORKDIR /src/picons

# fetch source
RUN \
	if [ -z ${RELEASE+x} ]; then \
	RELEASE=$(curl -u "${SECRETUSER}:${SECRETPASS}" -sX GET "https://api.github.com/repos/picons/picons/releases/latest" \
	| jq -r ".tag_name");	fi \
	&& set -ex \
	&& git clone -b "$RELEASE" https://github.com/picons/picons /src/picons \
	&& cp /src/backgrounds.conf /src/picons/build-input/


# build picons
RUN \
	./2-build-picons.sh snp-full

# archive picons
RUN \
	set -ex \
	&& mkdir -p \
		/build \
		/src/output \
	&& tar xf /src/picons/build-output/binaries-snp-full/*hardlink*.tar.bz2 -C \
	/src/output --strip-components=1 \
	&& tar -cjf /build/picons.tar.bz2 -C \
	/src/output . \
	&& chown -R 1000:1000 /build

# copy files out to /mnt
CMD ["cp", "-avr", "/build", "/mnt/"]

