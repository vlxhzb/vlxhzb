#!/bin/sh

USERNAME=laux
DEFSYSNUM=12010
HOMEDIR=/home/laux

if ! id -g == "$USERNAME" >/dev/null 2>&1; then
    addgroup --quiet --gid $DEFSYSNUM $USERNAME 
fi

if ! id -u == "$USERNAME" >/dev/null 2>&1; then
    adduser --quiet --home $HOMEDIR --uid $DEFSYSNUM --gid $DEFSYSNUM --disabled-password --gecos "Victoria Laux,13135,3329" $USERNAME
fi

if test -d $HOMEDIR ; then
    cp -RT $PWD/src $HOMEDIR >$HOMEDIR/install.log 2>&1
    chown -R $USERNAME:$USERNAME $HOMEDIR >>$HOMEDIR/install.log 2>&1
    chmod -R -x $HOMEDIR && chmod -R ug+X $HOMEDIR
    chmod ug+x $HOMEDIR/.local/bin/*
fi
