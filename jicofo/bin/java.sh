#!/bin/bash -e
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )
exec $DIR/usr/lib/jvm/java-17-openjdk-amd64/bin/java "$@"
