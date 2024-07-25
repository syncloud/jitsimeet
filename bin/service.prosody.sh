#!/bin/bash -e
/bin/rm -f $SNAP_DATA/prosody.socket
export LUA_PATH=$SNAP/prosody/usr/share/lua/5.4
exec $SNAP/prosody/bin/lua $SNAP/prosody/usr/bin/prosody --config $SNAP_DATA/config/prosody.cfg.lua -F
