#!/bin/bash

install() {
  sudo apt-get install build-essential
  sudo apt-get install openjdk-6-jdk
  sudo apt-get install ant
  sudo ln -s $PWD /builds
}

start() {
  rm -f slave.jar
  curl -O http://ci.jruby.org/jnlpJars/slave.jar 
  echo "Starting node"
  /sbin/start-stop-daemon --start --verbose --background --make-pidfile \
    --pidfile node.pid --exec /usr/bin/java --chdir $PWD \
    -- -jar slave.jar -jnlpUrl http://ci.jruby.org/computer/ubuntu-x86/slave-agent.jnlp
}

stop() {
  echo "Stopping node"
  /sbin/start-stop-daemon --stop --quiet --pidfile node.pid
}

case $1 in
  start)
    start
  ;;
  stop)
    stop
  ;;
  install)
    install
  ;;
  *)
    echo "unknown command $1. commands are start|stop|install"
    exit 1
  ;;
esac
