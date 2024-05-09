#!/bin/sh

default_ssh_user="ubuntu"
default_identity_file="$HOME/.ssh/id_rsa"

error() {
  echo "Error: $1" >&2
  exit 1
}

usage() {
  echo "SSH tunnel management tool."
  echo " "
  echo "$1 [-h/--help] [command] [options] arguments"
  echo " "
  echo "Commands:"
  echo "  open                      opens a new tunnel"
  echo "  stop                      stops an existing tunnel"
  echo "  list                      print current open tunnels"
  echo "  clean                     closes all current open tunnels"
  echo " "
  echo "Options:"
  echo "  -h, --help                show brief help"
  echo " "
}

open_usage() {
  echo "Open a new tunnel."
  echo " "
  echo "$1 open [options] host range"
  echo " "
  echo "Arguments:"
  echo "  host                        the bastion endpoint"
  echo "  range                       the cidr block to connect to"
  echo " "
  echo "Options:"
  echo "  -h, --help                  show brief help"
  echo "  -d, --debug                 writes the tunnel output to a log file"
  echo "  -o, --only                  fail if there's another tunnel to the same host"
  echo "  -u, --user <user>           the ssh username (default \"$default_ssh_user\")"
  echo "                              can also be set with TUNNEL_SSH_USER environment variable"
  echo "  -i, --identity-file <path>  the ssh identity file (default \"$default_identity_file\")"
  echo "                              can also be set with TUNNEL_SSH_IDENTITY_FILE environment variable"
  echo " "
}

open_tunnel() {
  args=$1
  host=$2
  range=$3
  only=$4
  debug=$5
  user=$6
  key_file=$7

  if [ $args -ne 2 ]; then
    open_usage $0
    error "Only 2 arguments are required: 'host' and 'range'."
    exit 1
  fi

  if [ -z ${host} ]; then
    open_usage $0
    error "Missing required 'host' argument."
    exit 1
  fi
  if [ -z ${range} ]; then
    open_usage $0
    error "Missing required 'range' argument."
    exit 1
  fi
  if [ -z ${user} ]; then
    open_usage $0
    error "Missing required SSH user."
    exit 1
  fi
  if [ -z ${key_file} ]; then
    open_usage $0
    error "Missing required SSH identity file."
    exit 1
  fi

  pid_file="/tmp/tunnel-id-$host"
  if test -f "$pid_file"; then
    echo "There's already one tunnel opened to $host."
    exit $only
  fi

  log_file="/dev/null"
  if [ $debug -eq 1 ]; then
    log_file="/tmp/tunnel-log-$host.log"
  fi

  nohup sshuttle --dns --disable-ipv6 -NHr $user@$host $range --ssh-cmd "ssh -i "$key_file" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" >$log_file 2>&1 &
  pid=$!
  if [ -z "${pid}" ]; then
    error "Could not establish connection to $host."
  fi

  echo $pid > $pid_file
  echo "Connection established to $host."
  exit 0
}

close_usage() {
  echo "Close an existing tunnel."
  echo " "
  echo "$1 close [options] host"
  echo " "
  echo "Arguments:"
  echo "  host                      the bastion endpoint"
  echo " "
  echo "Options:"
  echo "  -h, --help                show brief help"
  echo "  -m, --must                fail if there's no tunnel open to the given host"
  echo " "
}

close_tunnel() {
  args=$1
  host=$2
  must=$3

  if [ $args -ne 1 ]; then
    close_usage $0
    error "Only 1 argument is required: 'host'."
    exit 1
  fi

  pid_file="/tmp/tunnel-id-$host"
  if ! test -f "$pid_file"; then
    echo "There's no tunnel opened for $host."
    exit $must
  fi

  pid="$(cat $pid_file)"
  kill -9 "$pid"
  rm -f "$pid_file"
  
  echo "Connection closed to $host."
  exit 0
}

get_all_pids() {
  os="$(uname -s)"
  if [ $os = "Darwin" ]; then
    ps aux | grep -i "[s]shuttle --dns" | awk '{print $2}'
  else
    ps aux | grep -i "[s]shuttle --dns" | awk '{print $1}'
  fi
}

get_all_ids() {
  ls "/tmp/"tunnel-id-* 2>/dev/null
}

list_tunnels() {
  pids="$(get_all_pids)"
  if [ ! -z "${pids}" ]; then
    echo "Dangling tunnels (processes PIDs):"
    for p in ${pids}; do
      echo "- $p"
    done
  else
    echo "No dangling tunnel found."
  fi

  ids="$(get_all_ids)"
  if [ ! -z "${ids}" ]; then
    echo "Managed tunnels (ID files):"
    for p in ${ids}; do
      echo "- $p"
    done
  else
    echo "No managed tunnel found."
  fi

  exit 0
}

clean_tunnels() {
  pids="$(get_all_pids)"
  if [ ! -z "${pids}" ]; then
    printf "Closing active processes... "
    kill -9 $pids
    printf "done.\n"
  else
    echo "No dangling tunnel found."
  fi

  ids="$(get_all_ids)"
  if [ ! -z "${ids}" ]; then
    printf "Releasing tunnel IDs... "
    rm -f $ids
    printf "done.\n"
  else
    echo "No managed tunnel found."
  fi

  exit 0
}

if [ $# -eq 0 ]; then
  usage $0
  exit 1
fi

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      usage $0
      exit 0
      ;;
    open)
      shift;

      open_only=0
      open_debug=0
      open_user="${TUNNEL_SSH_USER:-$default_ssh_user}"
      open_identity_file="${TUNNEL_SSH_IDENTITY_FILE:-$default_identity_file}"

      while test $# -gt 0; do
        case "$1" in
          -h|--help)
            open_usage $0
            exit 0
            ;;
          -o|--only)
            shift;
            open_only=1
            ;;
          -d|--debug)
            shift;
            open_debug=1
            ;;
          -u|--user)
            shift;
            open_user=$1
            shift;
            ;;
          -i|--identity-file)
            shift;
            open_identity_file=$1
            shift;
            ;;
          *)
            open_tunnel $# $1 $2 $open_only $open_debug $open_user $open_identity_file
            break
            ;;
        esac
      done
      ;;
    close)
      shift;

      close_must=0

      while test $# -gt 0; do
        case "$1" in
          -h|--help)
            close_usage $0
            exit 0
            ;;
          -m|--must)
            shift;
            close_must=1
            ;;
          *)
            close_tunnel $# $1 $close_must
            break
            ;;
        esac
      done
      ;;
    list)
      shift;
      list_tunnels
      break
      ;;
    clean)
      shift;
      clean_tunnels
      break
      ;;
    *)
      usage $0
      error "Unkown command: $1."
      break
      ;;
  esac
done