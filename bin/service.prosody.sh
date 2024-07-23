#!/bin/bash -e
/bin/rm -f $SNAP_DATA/prosody.socket
exec $SNAP/prosody/bin/lua $SNAP/prosody/usr/bin/prosody --config $SNAP_DATA/config/prosody.cfg.lua -F
