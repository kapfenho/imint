#!/bin/sh

set -o errexit
set -o nounset

# execute this script on the developer machine
# this script copies the two necessary files to the application 
# server and creates the application directories
#
# NOTE:
# you need to configure the three variables below:
# user - username with wich to login
# server - server where to deploy
# apphome - desired application home directory

user=iam
server=iam.vie.agoracon.at
fmw=/appl/iam/fmw
apphome=${fmw}/config/deploy/imint

# create application directories 
ssh ${user}@${server} "mkdir -p ${apphome}/{archive,new/lib,current/plan}"
ssh ${user}@${server} "mkdir -p \${HOME}/.wlst"
ssh ${user}@${server} "mkdir -p \${HOME}/lib"

# copy necessary files
scp ${PWD}/setup/Plan.xml ${user}@${server}:${apphome}/current/plan
scp ${PWD}/setup/deploy.py ${user}@${server}:\${HOME}/lib
scp ${PWD}/setup/imint.prop ${user}@${server}:\${HOME}/.wlst

exit 0

