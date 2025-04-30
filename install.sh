#!/bin/sh

if ! id -u == "laux" >/dev/null 2>&1; then
    adduser -r -s /bin/zsh laux -d /home/laux
fi

cp -av src/* ~laux/
