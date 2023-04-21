
echo "input local sudo password"
ansible-playbook \
    --ask-become-pass \
    --inventory $PWD/ansible-inventories \
    $PWD/../../../.seed/ansible-playbook/local.init.yml

echo "input remote sudo password"
ansible-playbook \
    --ask-become-pass \
    --inventory $PWD/ansible-inventories \
    $PWD/../../../.seed/ansible-playbook/remote.init.yml