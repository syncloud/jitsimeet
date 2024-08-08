#!/bin/bash -e
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )
exec $DIR/bin/lua $DIR/usr/bin/prosodyctl --config /var/snap/jitsimeet/current/config/prosody.cfg.lua "$@"