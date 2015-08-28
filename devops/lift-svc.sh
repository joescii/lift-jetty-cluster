#!/usr/bin/env bash
#

case "$1" in
  start)
    cd /opt/lift/
    /opt/lift/target/universal/stage/bin/lift-jetty-cluster-aws &
    disown $!

    ;;

  stop)

    ;;

  restart)

    ;;

  supervise)

    ;;

  run|demo)

    ;;

  check|status)

    ;;

  usage

    ;;
esac

exit 0
