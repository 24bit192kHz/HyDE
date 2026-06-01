#!/usr/bin/env sh
# Wrapper to make our scripts work both with and without systemd.

if [ -d "/run/systemd/system" ]; then
    exec app2unit "$@"
fi
# no systemd: drop args before -- and run only the command after --
while [ "$#" -gt 0 ] && [ "$1" != "--" ]; do
    shift
done
[ "$#" -gt 0 ] && shift
exec "$@"
