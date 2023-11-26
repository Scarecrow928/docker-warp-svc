# Stage 1: Download cloudflare-warp deb package
FROM debian:bookworm-slim as download
ARG DEBIAN_FRONTEND=noninteractive
RUN cd /tmp && \
  apt update && \
  apt install -y curl gnupg && \
  curl https://pkg.cloudflareclient.com/pubkey.gpg | \
  gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ bookworm main" | \
  tee /etc/apt/sources.list.d/cloudflare-client.list && \
  apt update && \
  apt download cloudflare-warp

# Stage 2: Install cloudflare-warp
FROM debian:bookworm-slim
ARG DEBIAN_FRONTEND=noninteractive
ARG WARP_DIR=/var/lib/cloudflare-warp
ARG LOG_REDIRECTION_DEST=/dev/null
COPY --from=download /tmp/cloudflare-warp*.deb /tmp/
COPY --from=download /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg /usr/share/keyrings/
COPY --from=download /etc/apt/sources.list.d/cloudflare-client.list /etc/apt/sources.list.d/
RUN cd /tmp && \

  # install fron a deb package
  dpkg -i cloudflare-warp*.deb || true && \

  # fix dependencies
  apt update && \
  apt install -f -y && \

  # clean tmp files, caches
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/* && \

  # useless files
  rm -f /usr/bin/warp-taskbar && \

  # redirect logs
  mkdir -p ${WARP_DIR} && \
  ln -s ${LOG_REDIRECTION_DEST} ${WARP_DIR}/cfwarp_daemon_dns.txt && \
  ln -s ${LOG_REDIRECTION_DEST} ${WARP_DIR}/cfwarp_service_dns_stats.txt && \
  ln -s ${LOG_REDIRECTION_DEST} ${WARP_DIR}/cfwarp_service_stats.txt && \
  ln -s ${LOG_REDIRECTION_DEST} ${WARP_DIR}/cfwarp_service_boring.txt && \
  ln -s ${LOG_REDIRECTION_DEST} ${WARP_DIR}/cfwarp_service_log.txt
EXPOSE 40000
CMD [ "/bin/warp-svc" ]
