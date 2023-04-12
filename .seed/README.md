
## use

install git-subrepo
```bash
git clone https://github.com/ingydotnet/git-subrepo $HOME/git-subrepo
echo "source $HOME/git-subrepo/.rc" >> ~/.bashrc
```

first add subrepo
```
git subrepo clone git@gitlab.lan:homelab/seed-ansible-path.git .seed -b master -m "Update .seed"
```

loop
```
git subrepo pull .seed -b master
git subrepo push .seed -b master
```