docker run -dit \
  -v $PWD/docker/dupeguru:/config \
  -v $PWD:/storage \
  -e ENABLE_CJK_FONT=1 \
  -p 5800:5800 \
  --name dupeguru \
  --hostname dupeguru \
  --restart always \
  --user="root:root" \
  --privileged \
  jlesage/dupeguru:latest