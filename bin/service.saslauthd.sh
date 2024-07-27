#!/bin/bash -e
exec $SNAP/prosody/bin/saslauthd -a ldap -O $SNAP_DATA/config/saslauthd.conf -c -m $SNAP_DATA/saslauthd -n 5 -d
