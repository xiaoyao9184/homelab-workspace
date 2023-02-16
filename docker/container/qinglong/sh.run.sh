docker run -d \
  --name=dupeguru \
  -p 5800:5800 \
  -v $PWD:/storage:rw \
  jlesage/dupeguru
