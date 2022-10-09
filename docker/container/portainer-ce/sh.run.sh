docker volume create portainer_data

docker run -d \
  -p 9000:9000 \
  -p 9443:9443 \
  -p 8000:8000 \
  --hostname portainer-ce \
  --name portainer-ce \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest