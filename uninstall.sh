#!/bin/sh

USERNAME=laux
HOMEDIR=/home/laux

sudo deluser $USERNAME

sudo rm -rf $HOMEDIR
