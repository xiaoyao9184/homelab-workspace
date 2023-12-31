docker run -d \
  -p 9001:9001 \
  --hostname portainer-agent \
  --name portainer-agent \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/docker/volumes:/var/lib/docker/volumes \
  portainer/agent:latest