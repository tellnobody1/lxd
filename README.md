# LXD 

LXD hypervisor and containers to create test clusters.

[LXD documentation](http://www.ubuntu.com/cloud/tools/lxd)

# Control Panel

```bash
andreyza@nb-anza:~/prj/lxd$ ./ctl
Usage: ctl [command] [params]

Supported commands are:
LXD:
  list - Output LXD containers list.
  stop <name> - Stop container by name.
  forward <port> <IP> - Forward port to container IP.
Containers:
  ip <name> - Returns the container IP by name.
OGW:
MWS AS:
  mws init <container> - Init MWS on container. Push start script and configuration.

Examples:

```

# Examples

The list of containers:

```bash
./ctl list
+------+---------+------------+------+-----------+-----------+
| NAME |  STATE  |    IPV4    | IPV6 | EPHEMERAL | SNAPSHOTS |
+------+---------+------------+------+-----------+-----------+
| az0  | RUNNING | 10.0.3.63  |      | NO        | 0         |
| az1  | RUNNING | 10.0.3.194 |      | NO        | 0         |
| az2  | RUNNING | 10.0.3.27  |      | NO        | 0         |
| az3  | RUNNING | 10.0.3.33  |      | NO        | 0         |
| az4  | RUNNING | 10.0.3.238 |      | NO        | 0         |
| az5  | RUNNING | 10.0.3.239 |      | NO        | 0         |
| az6  | RUNNING | 10.0.3.149 |      | NO        | 0         |
| az7  | RUNNING | 10.0.3.200 |      | NO        | 0         |
| az8  | RUNNING | 10.0.3.207 |      | NO        | 0         |
| az9  | RUNNING | 10.0.3.167 |      | NO        | 0         |
+------+---------+------------+------+-----------+-----------+
```
