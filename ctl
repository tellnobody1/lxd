#! /bin/bash

SELF=`basename $0`
MWS_HOME=/home/ubuntu/apps/mws-core

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
  echo "Looking for $1"
  lxc info $1 | grep "eth0:" | awk '{print $3}'
  #lxc list | awk -v n1=$1 'NR>2 && $2==n1 && $4=="RUNNING" {print $6}'
}

function forward(){
  echo "try forward $1 $2"
  sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $1 -j DNAT --to-destination $2:$1
  sudo iptables -A FORWARD -i eth0 -p tcp --dport $1 -j ACCEPT
  sudo iptables-save
  echo "sudo iptables -nL --line-numbers"
}

function a() {
  echo "A"
}

case "$1" in
  mws)
    if [ $# -ne 3 ]; then 
      echo "Usage: $SELF mws init <node>"
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
    printf "\t%s - %s\n" "forward <port> <IP>" "Forward port to container IP."
    printf "Containers:\n"
    printf "\t%s - %s\n" "ip <name>" "Returns the container IP by name."
    printf "OGW:\n"
    printf "MWS AS:\n"
    printf "\t%s - %s\n" "mws init <container>" "Init MWS on container. Push start script and configuration."
    printf "\t%s - %s\n" "mws start <container>" "Init MWS on container. Push start script and configuration."
    printf "\n"
    printf "Examples:\n"
    printf "\t"
    printf "\t"
    printf "\n"
  exit 1
  ;;
esac

