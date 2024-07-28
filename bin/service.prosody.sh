#!/bin/bash -xe
/bin/rm -f $SNAP_DATA/prosody.socket
LUA="5.4"
export LUA_PATH="$SNAP/prosody/usr/share/lua/$LUA/?.lua"
export LUA_PATH="$LUA_PATH;$SNAP/prosody/usr/local/share/lua/$LUA/?.lua"
export LUA_PATH="$LUA_PATH;$SNAP/prosody/usr/lib/prosody/modules/?.lua"
LIBS=$(echo $SNAP/prosody/usr/lib/*-linux-gnu*)
export LUA_CPATH="$LIBS/lua/$LUA/?.so"
export LUA_CPATH="$LUA_CPATH;$SNAP/prosody/usr/local/lib/lua/$LUA/?.so"
exec $SNAP/prosody/bin/lua $SNAP/prosody/usr/bin/prosody --config $SNAP_DATA/config/prosody.cfg.lua -F
