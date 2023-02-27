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
| [stack-standalone](./stack-standalone/) | stack-standalone | isolated service |
| [stack-scale](./stack-scale/) | stack-scale | cluster services |

The subfolder is usually the project name for compose, for stack name for stack.

> Use `compose-standalone` if special permissions are required, or use those in docker-compose-swarm.
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

> Use `stack-standalone` if only isolated service, but it needs to be managed by swarm.

> Use `stack-scale` if cluster services.

In `stack-` subfolder According to the folder prefix, you can know its cluster mode. 

| **prefix**/`regex` | dir | features |
|:----- |:----- |:----- |
| **fixed-** | [stack-standalone](./stack-standalone/) | one service only run on fixed node |
| **anyone-** | [stack-standalone](./stack-standalone/) | one service support disaster recovery on any node |
| `^node\d+-` | [stack-scale](./stack-scale/) | fixed number of multiple services |
| `^max\d+-` | [stack-scale](./stack-scale/) | fixed number of multiple services and allows with fewer services |
| **global-** | [stack-scale](./stack-scale/) | not fixed number of multiple services, each node run one service |
| `^roles\d+-` | [stack-scale](./stack-scale/) | fixed number of multiple services have roles |
| `^min\d+-` | [stack-scale](./stack-scale/) | fixed number of multiple services have roles and allows with fewer services |
| **roles-** | [stack-scale](./stack-scale/) | Not fixed number of multiple services have roles |

There is a single point of failure on a [stack-standalone](./stack-standalone/), 
when it crashes, service will be restarted by default one the original node.
Usually [stack-scale](./stack-scale/) services without roles are suitable for high availability.

> Use `^node\d+-` `^max\d+-` or **global-** when service enable scaling without roles 
> - like [node3-itsaur-zookeeper](./stack-scale/node3-itsaur-zookeeper/)
> - like [max3-alibaba-canal](./stack-scale/max3-alibaba-canal/)
> - like [global-docker-telegraf](./stack-scale/global-gitlab-runner/)

> Use `^roles\d+-` `^min\d+-` or **roles-** when service enable scaling and has roles like master-slave, and only in the case of interdependence
> - like [roles3-tonimoreno-influxdb](./stack-scale/roles3-tonimoreno-influxdb/) using _srelay_ requires at least 2 backend services, total of 3 services.
> - like [min1-crunchydata-postgres](./stack-scale/min1-crunchydata-postgres/) using _srelay_ requires at least 2 backend services, total of 3 services.
> - like [roles-portainer-ce](./stack-scale/roles-portainer-ce/) although the `portainer` service is standalone, but it cant miss `agent` service that enables scaling, `portainer` and `agent` need to be considered as a whole.
> - not like [global-gitlab-runner](./stack-scale/global-gitlab-runner/) as slave dependent [anyone-gitlab-ce](./stack-standalone/anyone-gitlab-ce/), because `gitlab-ce` can run alone, or run with [anyone-gitlab-runner](./stack-scale/anyone-gitlab-runner/)


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


## replicated mode for standalone

> Always use `replicated` mode with `replicas: 1` for standalone.

[stack-standalone](./stack-standalone/)/**fixed-** and
[stack-standalone](./stack-standalone/)/**anyone-** always run one just one service.

failover of fixed it is decided based on whether shared volumes are supported.


## global mode for port publishing or scale growth

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

> When the service supports arbitrary growth or reduction, the `global` mode should be used.

[stack-scale](./stack-scale/)/**global-** use `global` mode,

[stack-scale](./stack-scale/)/**roles-** use `global` mode,
use constraint control scale number


## replicated mode for port publishing or scale sensitive

> Use replicated mode if publishing post with set [max_replicas_per_node](#max-replicas-per-node) to `1`

> Use replicated mode for some services are sensitive for number of scale
> - like clickhouse, cannot add nodes growth service.

[stack-scale](./stack-scale/)/`^node\d+-` use `replicated` mode,

[stack-scale](./stack-scale/)/`^max\d+-` use `replicated` first, 
or use a different service name with `replicas: 1`.

[stack-scale](./stack-scale/)/`^roles\d+-` use `replicated` first, 
or use a different service name with `replicas: 1`.

[stack-scale](./stack-scale/)/`^min\d+-` use `replicated` first, 
or use a different service name with `replicas: 1`.

### max replicas per node

[max_replicas_per_node](https://docs.docker.com/compose/compose-file/compose-file-v3/#max_replicas_per_node) constraint
limit the number of replicas that can run on one node.


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
