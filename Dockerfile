FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG WARP_DIR=/var/lib/cloudflare-warp
ARG LOG_REDIRECTION_DEST=/dev/null

RUN apt update && \
  apt upgrade -y && \
  apt install -y curl gnupg && \
  curl https://pkg.cloudflareclient.com/pubkey.gpg | \
  gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ bookworm main" | \
  tee /etc/apt/sources.list.d/cloudflare-client.list && \
  apt update && \
  apt install -y cloudflare-warp && \
  apt autoclean && \
  apt autoremove && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p ${WARP_DIR} && \
  ln -s ${LOG_REDIRECTION_DEST} ${WARP_DIR}/cfwarp_daemon_dns.txt && \
  ln -s ${LOG_REDIRECTION_DEST} ${WARP_DIR}/cfwarp_service_dns_stats.txt && \
  ln -s ${LOG_REDIRECTION_DEST} ${WARP_DIR}/cfwarp_service_stats.txt && \
  ln -s ${LOG_REDIRECTION_DEST} ${WARP_DIR}/cfwarp_service_boring.txt && \
  ln -s ${LOG_REDIRECTION_DEST} ${WARP_DIR}/cfwarp_service_log.txt

EXPOSE 40000

CMD [ "/bin/warp-svc" ]
