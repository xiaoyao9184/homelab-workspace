
## owner

install git-subrepo
```bash
git clone https://github.com/ingydotnet/git-subrepo $HOME/git-subrepo
echo "source $HOME/git-subrepo/.rc" >> ~/.bashrc
```

first init subrepo
```bash
git subrepo init .seed \
    -r git@gitlab.lan:homelab/seed-ansible-path.git \
    -b master
```

loop push
```bash
git subrepo push .seed -b master
```

also can pull like [collaborator](#collaborator)


## collaborator

install git-subrepo
```bash
git clone https://github.com/ingydotnet/git-subrepo $HOME/git-subrepo
echo "source $HOME/git-subrepo/.rc" >> ~/.bashrc
```

first clone subrepo
```bash
git subrepo clone git@gitlab.lan:homelab/seed-ansible-path.git \
    .seed \
    -b master \
    -m "Init .seed"
```

loop pull
```bash
git subrepo pull .seed -b master -m "Update .seed"
```

also can push like [owner](#owner)
