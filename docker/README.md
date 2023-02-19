# dir classification

Docker service appears in docker-compose and docker-swarm.

Use `docker-compose` or `docker compose` command to run services on a single-node docker host,
`docker stack` command for run services on cluster(swarm) docker hosts.

And docker-swarm service support scale, for disaster recovery to provide high availability.

So the division is as follows

| name | service type | scale use |
|:----- |:-----:|:----- |
| compose-standalone | compose | no |
| stack-standalone | stack | no |
| stack-scale | stack | yes | 

You can find the division of each directory according to the following table.

| dir | name | features |
|:----- |:----- |:----- |
| [compose-standalone](./compose-standalone/) | compose-standalone | |
| [stack-standalone-fixed](./stack-standalone-failover/) | stack-standalone | only run on fixed node |
| [stack-standalone-failover](./stack-standalone-failover/) | stack-standalone | support disaster recovery |
| [stack-master-slave](./stack-master-slave/) | stack-scale | services have roles |
| [stack-high-availability](./stack-high-availability/) | stack-scale | services between equality |


> Use `compose-*` if special permissions are required, or use those in docker-compose-swarm
> - build
> - cap_add 
> - cap_drop
> - cgroup_parent
> - container_name
> - depends_on
> - devices
> - external_links
> - links
> - network_mode
> - restart
> - security_opt
> - tmpfs
> - userns_mode

> Use `stack-master-slave` when service enable scaling and master-slave dependent
> - like [gitlab-runner-global](./stack-master-slave/gitlab-runner-global/) as slave dependent [gitlab-ce](./stack-standalone/gitlab/)
> - other like [portainer-ce-global](./stack-master-slave/portainer-ce-global/) although the `portainer` service is standalone, but it cant miss `agent` service that enables scaling, `portainer` and `agent` need to be considered as a whole.

> Use `stack-high-availability` when service enable scaling equality between services


# stack mode

Docker stack service has two modes `global` and `replicated`

| mode | node relationship | scenes to be used |
|:----- |:----- |:----- |
| global | one service one node | use many nodes as possible |
| replicated | multiple services on one node | use fewer nodes if enough resources |

When `global`, the number of services is always less than the number of nodes.

When `replicated` the number of services is independent of the number of nodes.

| mode | max number of service | automatic growth |
|:----- |:----- |:----- |
| global | equal to the number of nodes | yes |
| replicated | stack definition | no |

| mode | min number of service | constraint reduce number | constraint number to 0 |
|:----- |:----- |:----- |:----- |
| global | 1 | yes | yes |
| replicated | stack definition |no: total | yes |
|  |  | yes: one node [max_replicas_per_node*](#max-replicas-per-node) |


## replicated mode standalone

> Always use `replicated` mode with `replicas: 1` for standalone.

[stack-standalone-failover](./stack-standalone-failover/) and 
[stack-standalone-fixed](./stack-standalone-fixed/) always run one just one service.

failover of fixed it is decided based on whether shared volumes are supported.


## global mode scale publishing

On the other hand, service can publish the port to docker host

| publish | alias | 
|:----- |:-----:|
| yes | endpoint service |
| no | agent service |

Problems arise when the two are combined

| mode | publish | publish |
|:----- |:-----:|:----- |
| global | yes | Very good, support load balancing and disaster recovery |
| global | no | ok |
| replicated | no | Not work, port conflicts when multiple services are on same node |
|  | yes | If set constraint [max_replicas_per_node](#max-replicas-per-node) to `1` |
| replicated | no | ok |

> So always use `global` mode for publishing

[stack-master-slave](./stack-master-slave/) and 
[stack-high-availability](./stack-high-availability/) use `global` first,
use constraint control scale number


## replicated mode scale publishing

So if use replicated mode with publishing must set [max_replicas_per_node](#max-replicas-per-node) to `1`

### max replicas per node

[max_replicas_per_node](https://docs.docker.com/compose/compose-file/compose-file-v3/#max_replicas_per_node) constraint
limit the number of replicas that can run on one node.


## global mode scale growth

When the service supports arbitrary growth or reduction, the `globa` mode should be used.


## replicated mode scale sensitive

Some services are sensitive for number of scale, like clickhouse, cannot add nodes growth service.


# file classification

It is logically, it is divided into two categories according to whether the service is exited or not.

- continuous service
- job service

Reflected by ansible file name

| ansible playbook name | name | 
|:----- |:----- |
| ansible-playbook.deploy.yml | continuous | 
| ansible-playbook.run.yml | job | 

Job service run and exit, so does not need resources reservations,
and no [dir classification](#dir-classification) is established.