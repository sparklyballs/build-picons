FROM debian:bookworm-slim

COPY backgrounds.conf /src/
RUN \
	apt-get update \
	&& apt-get install \
		--no-install-recommends \
		-y \
		binutils \
		bzip2 \
		ca-certificates \
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

WORKDIR /src/picons

RUN \
	git clone https://github.com/picons/picons /src/picons \
	&& cp /src/backgrounds.conf /src/picons/build-input/


RUN \
	./2-build-picons.sh snp-full

RUN \
	set -ex \
	&& mkdir -p \
		/build \
	&& cp /src/picons/build-output/binaries-snp-full/*hardlink*.tar.bz2 /build/picons.tar.bz2 \
	&& chown -R 1000:1000 /build

# copy files out to /mnt
CMD ["cp", "-avr", "/build", "/mnt/"]


