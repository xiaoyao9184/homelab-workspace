# homelab-workspace


## agreement

- directory `.config` using git submodules
- directory `.seed` using git subrepo

### about .config

Directory `.config` places host-related custom variables and configuration files, 
which are not universal and may contain sensitive key information, 
so the git submodule is selected as an external reference,
because the logic in the project is heavily dependent on the files in it or variables, 
so this project provides a `.config` submodule repository [homelab-config](https://github.com/lab4x/homelab-config.git) containing examples,
This submodule repository is only used to demonstrate the functions of this project. 

**NOTE: If you plan to use this project, you should provide your own .config submodule and override it**

See how to use custom .config submodules at [custom .config](#custom-config)


### about .seed

Directory `.seed` places the logic shared by multiple projects.
This project originates from the personal `homelab` project, these logics are born here. 
Its name comes from the [docker-seed](https://github.com/xiaoyao9184/docker-seed) project, and this project also conforms to the `workspace` defined by `docker-seed`. 
Here they will be used through [git subrepo](https://github.com/ingydotnet/git-subrepo) technology, `git subrepo` technology is transparent to users who use this project, and they can be used directly as ordinary files without caring about internal details.


## use


### download project

Clone this project with examples .config submodule 

```bash
git clone --recurse-submodules https://github.com/lab4x/homelab-workspace.git
```

### custom .config

Using custom `.config` submodule like `git@gitlab.lan:homelab/homelab-config-4x.git`

Start from zero, did not clone `homelab-workspace`

```bash
git clone git@gitlab.lan:homelab/homelab-workspace.git
git submodule init
git config submodule..config.url git@gitlab.lan:homelab/homelab-config-4x.git
git submodule update --recursive --remote
```

Already cloned, Modify `homelab-workspace` to use new `.config` submodule

```bash
git submodule deinit -f .config
rm -rf .git/modules/.config/
git config submodule..config.url git@gitlab.lan:homelab/homelab-config-4x.git
git submodule update --recursive --remote
```

To quickly switch `.config` submodule please use [.config-changer](./.config-changer.sh)
```bash
bash ./.config-changer.sh
```
**Note: Push .config submodules commits before switching for avoid lost changes**
