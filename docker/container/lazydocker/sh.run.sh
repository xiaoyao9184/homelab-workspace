docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $PWD/lazydocker:/.config/jesseduffield/lazydocker \
    lazyteam/lazydocker:latest