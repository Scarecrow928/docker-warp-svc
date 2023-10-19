FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

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
  rm -rf /var/lib/apt/lists/*

EXPOSE 40000

VOLUME [ "/var/lib/cloudflare-warp/settings.json" ]
VOLUME [ "/var/lib/cloudflare-warp/conf.json" ]
VOLUME [ "/var/lib/cloudflare-warp/reg.json" ]

CMD [ "/bin/warp-svc" ]
