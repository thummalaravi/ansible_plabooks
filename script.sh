#!/bin/sh

URL=https://github.com/saishiva0603/project4/
FIRSTNAME=ansible-
LASTNAME=$(git ls-remote $URL HEAD|cut -c 1-40)
FULLNAME="$FIRSTNAME$LASTNAME"
cd ~
export AMINAME=$FULLNAME
echo $FULLNAME



cd /etc/ansible/
ansible-playbook clone.yml

