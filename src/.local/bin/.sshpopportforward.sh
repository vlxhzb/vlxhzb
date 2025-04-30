#!/bin/sh

############################################
# Description:
#    Simple script to establish an SSH tunnel to a remote
#    POP3 server.
# Author:  Mike Pilone
# License: BSD
##############################################

# Edit the following variables to configure the script

# The username used to connect to the mail server. Note that this
# may not be your POP3 username, but the username used in an SSH
# connection.
SSH_USERNAME="laux"

# The name of the mail server to connect to. This server is assumed to 
# be running an SSH daemon as well.
SSH_SERVER=imap.acc.bessy.de

# Advanced option. The name or ip address of the machine that the
# port should actually be forwarded to. Note that the session will
# not be encryped from SSH_SERVER to this machine, so it is not normally
# a good idea to use this option. One case where this option makes sense, 
# is if the SSH server is the firewall box and the mail server is another
# machine behind that firewall. By default, this option assumes that
# your mail server is the same as the SSH server.
SSH_MAIL_SERVER=localhost

#####################################################
# Do not edit anything below this line
#####################################################

# The SSH command which will establish the connection to the mail server.
# Port 11110 on the local machine will be forwarded to port 110 on the mail
# server, through a secure tunnel. The sleep command gives KMail enough time
# to open the POP3 connection. SSH will keep the tunnel open as long as it
# is active.
ssh -C -f $SSH_USERNAME@$SSH_SERVER -L 11143:$SSH_MAIL_SERVER:143 'sleep 15'
