FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    cpanminus build-essential carton \
    libxml2-dev libexpat1-dev zlib1g-dev libssl-dev git libmysqlclient-dev \
    openssl ca-certificates && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/

RUN useradd app -s /usr/sbin/nologin && \
    echo "Asia/Tokyo" > /etc/timezone && dpkg-reconfigure tzdata

EXPOSE 5000
ENV APPROOT /app
RUN mkdir -p $APPROOT && chown app:app $APPROOT
WORKDIR $APPROOT

COPY cpanfile $APPROOT/cpanfile
COPY cpanfile.snapshot $APPROOT/cpanfile.snapshot
RUN carton install --deployment
COPY ./ $APPROOT

RUN chown app:app -R $APPROOT
USER app
CMD ["carton", "exec", "--", "plackup", "--server", "Starlet"]
