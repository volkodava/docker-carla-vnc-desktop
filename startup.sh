#!/bin/bash

set -vxu

# run supervisor
/usr/bin/supervisord -c ${HOME}/supervisord.conf

${SHELL}