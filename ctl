#! /bin/bash

SELF=`basename $0`
MWS_HOME=/home/ubuntu/prj/mwss
CTL_HOME="$(cd "$(cd "$(dirname "$0")"; pwd -P)"; pwd)"

function init(){
  echo "init $1"
  echo "$1$MWS_HOME/start"

  lxc file push --mode=0777 start "$1$MWS_HOME/start"
  lxc exec $1 -- chown ubuntu:ubuntu "$MWS_HOME/start"
  #lxc file push ext.conf $1$MWS_HOME"/conf/ext.conf"
}

function start(){
  echo "start MWS AS on $1"
  lxc exec $1 "$MWS_HOME/start"
}

function ip(){
  local lip=$(lxc info $1 | grep "eth0:" | awk '{print $3}')
  echo "$lip"
  #lxc list | awk -v n1=$1 'NR>2 && $2==n1 && $4=="RUNNING" {print $6}'
}

function forward(){
  echo "try forward $1 $2"
  sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $1 -j DNAT --to-destination $2:$1
  sudo iptables -A FORWARD -i eth0 -p tcp --dport $1 -j ACCEPT
  sudo iptables-save
  echo "sudo iptables -nL --line-numbers"
}

function jmx() {
  java -jar $CTL_HOME/jmxsh-R5.jar -h `ip $1` -p 9999 /dev/fd/0
}

function invoke() {
  echo jmx_invoke -m akka:type=Cluster "$@" | $JMX_CLIENT
}

function get() {
  echo "puts [jmx_get -m akka:type=Cluster \"$1\"]" | jmx $2
}

function ensure() {
  REPLY=$(get Available $1) # redirects STDERR to STDOUT before capturing it
  if [[ "$REPLY" != *true ]]; then
    echo "MWS cluster node is not available on $1"
    exit 1
  fi
}

case "$1" in
  mws)
    if [ $# -ne 3 ]; then 
      echo "Usage: $SELF mws <command> <node>"
      exit 1
    fi
    shift 1
    case "$1" in
      init)
        init $2
        ;;
      start)
        start $2
        ;;
      status)
        ensure $2
        echo "Querying cluster status $2"
        get ClusterStatus $2
        ;;
      *)
      echo "unknow command"
      ;;
    esac
    ;;
  ip)
    if [ $# -ne 2 ]; then
      echo "Usage: $SELF ip <name>"
      exit 1
    fi
    ip $2
    ;;
  forward)
    if [ $# -ne 3 ]; then
      echo "Usage: $SELF forward <port> <IP>."
      exit 1
    fi
    forward $2 $3
    ;;
  list)
    echo "`lxc list`"
    ;;
  start)
    if [ $# -ne 2 ]; then
      echo "Usage: $SELF start <name>|all"
      exit 1
    fi
    case "$2" in
      all)
        echo "Start all containers..."
        cts=(`lxc list | awk 'NR>2 && $4=="STOPPED" {print $2}'`)
        for n in ${cts[@]}; do lxc start $n; done
        lxc list
        echo "done!"
        ;;
      *)
        name=$2
        echo "Starting" $name
        lxc start $name
        echo "done!"
        lxc list
        ;;
    esac
    ;;
  stop)
    if [ $# -ne 2 ]; then
      echo "Usage: $SELF stop <name>"
      exit 1
    fi
    name=$2
    echo "Stoping container " $2 "..."
    code=$(lxc stop $2 2>&1 | grep -ci "error:")
    if [ $code -eq 1 ]; then
      echo "skip"
      lxc info $2
      exit 1
    else
      echo "done"
      exit 1
    fi
    ;;

  a)
    a
    ;;
  *)
    printf "Usage: $SELF [command] [params]\n\n"
    printf "Supported commands are:\n"
    printf "LXD:\n"
    printf "\t%s - %s\n" list "Output LXD containers list."
    printf "\t%s - %s\n" "stop <name>" "Stop container by name."
    printf "\t%s - %s\n" "start <name>|all" "Start [container by name] | [all containers]."
    printf "\t%s - %s\n" "forward <port> <IP>" "Forward port to container IP."
    printf "Containers:\n"
    printf "\t%s - %s\n" "ip <name>" "Returns the container IP by name."
    printf "OGW:\n"
    printf "MWS AS:\n"
    printf "\t%s - %s\n" "mws init <container>" "Init MWS on container. Push start script and configuration."
    printf "\t%s - %s\n" "mws start <container>" "Start MWS Application on container."
    printf "\t%s - %s\n" "mws status <container>" "Asks the MWS cluster for its current status on container."
    printf "\n"
    printf "Examples:\n"
    printf "\t"
    printf "\t"
    printf "\n"
  exit 1
  ;;
esac

# lxc exec az0 -- sudo apt-get install openjdk-7-jdk

# OGW
# lxc file push ~/.ssh/id_rsa.pub test1/home/ubuntu/.ssh/authorized_keys --mode=0600 --uid=1000
# lxc exec az0 -- tar -xf /home/ubuntu/prj/mwskaraf.tar.gz -C /home/ubuntu/prj
# lxc file push 2015-11-17T13:13:45Z.kar az0/home/ubuntu/prj/mwskaraf-15.7.15.4-10-gaa403a0/deploy/ogp.kar
# lxc file push 2015-11-17T13:43:04Z.kar az0/home/ubuntu/prj/mwskaraf-15.7.15.4-10-gaa403a0/deploy/mws.kar
# wget http://gitlab.ee.playtech.corp/mws/kar/raw/master/fragments/extdev1.kar

# sudo ln -s /home/ubuntu/prj/karaf/bin/KARAF-service /etc/init.d/
# 

# MWSS
# tar -cvzf mwss.tar.gz mwss
# lxc file push mwss.tar.gz az0/home/ubuntu/prj/
# lxc exec az0 -- tar -xf /home/ubuntu/prj/mwss.tar.gz -C /home/ubuntu/prj
