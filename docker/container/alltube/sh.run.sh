docker run -d --name=alltube \
  -p 8280:80 \
  -e PUID=1000 \
  -e PGID=1000 \
  --restart always \
  rudloff/alltube:latest
