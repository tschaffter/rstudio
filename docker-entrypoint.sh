#!/usr/bin/env bash

set -e

if [ "$1" = 'rstudio' ]; then
    # RStudio userconf.sh script runs RStudio as $USER
    exec /init
fi

exec /init gosu $USER "$@"