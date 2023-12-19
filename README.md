# docker-warp-svc
Cloudflare warp-svc in Docker

```bash
# start container
docker compose up -d

# register
yes | docker exec -it warp-svc warp-cli register

# set socks5 proxy port at 40000 and connect
docker exec -t warp-svc bash -c "warp-cli set-mode proxy; warp-cli set-proxy-port 40000; warp-cli connect"
```
