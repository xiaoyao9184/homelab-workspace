
# What to do

Ansible-related content will be placed here, 
running ansible command is always on the control node,
so it including initializing ansible.


# dir classification

The control node can only be linux, on windows system, 
you can run the ansible command through wsl or use [docker-seed](https://github.com/xiaoyao9184/docker-seed) i.e. run an ansible container on docker-desktop,
so use system names to specify subfolders.

So the division is as follows

| name | system |
|:----- |:-----:|
| pwsh@windows | windows |
| wsl@debian | debian |
| wsl@ubuntu | ubuntu |
