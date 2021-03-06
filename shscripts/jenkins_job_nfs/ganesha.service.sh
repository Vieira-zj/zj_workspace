#!/bin/sh
set -ex

CMD="ganesha.nfsd"
RUNAS="root"
NAME="ganesha"

PIDFILE=/var/run/$NAME.pid
LOGFILE=/var/log/$NAME.log

start() {
  if [ -f $PIDFILE ]; then
    if [ -n $(cat $PIDFILE) ]; then
      echo 'Service already running' >&2
    else
      echo 'Service pid is null' >&2
    fi
    return 1
  fi
  echo 'Starting service...' >&2
  su -c "$CMD & echo $! > $PIDFILE" $RUNAS
  echo 'Service started' >&2
}

stop() {
  if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
    echo 'Service not running' >&2
    return 1
  fi
  echo 'Stopping service...' >&2
  kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"
  echo 'Service stopped' >&2
}

uninstall() {
  echo -n "Are you really sure you want to uninstall this service? That cannot be undone. [yes|No] "
  local SURE
  read SURE
  if [ "$SURE" = "yes" ]; then
    stop
    rm -f "$PIDFILE"
    echo "Notice: log file is not be removed: '$LOGFILE'" >&2
    update-rc.d -f $NAME remove
    rm -fv "$0"
  fi
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  uninstall)
    uninstall
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|uninstall}"
esac

set +ex
