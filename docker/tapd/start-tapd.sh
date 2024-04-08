#!/usr/bin/env bash

# exit from script if error was raised.
set -e

# error function is used within a bash function in order to send the error
# message directly to the stderr output and exit.
error() {
    echo "$1" > /dev/stderr
    exit 0
}

# return is used within bash function in order to return the value.
return() {
    echo "$1"
}

# set_default function gives the ability to move the setting of default
# env variable from docker file to the script thereby giving the ability to the
# user override it during container start.
set_default() {
    # docker initialized env variables with blank string and we can't just
    # use -z flag as usually.
    BLANK_STRING='""'

    VARIABLE="$1"
    DEFAULT="$2"

    if [[ -z "$VARIABLE" || "$VARIABLE" == "$BLANK_STRING" ]]; then

        if [ -z "$DEFAULT" ]; then
            error "You should specify default variable"
        else
            VARIABLE="$DEFAULT"
        fi
    fi

   return "$VARIABLE"
}

# Set default variables if needed.
NETWORK=$(set_default "$NETWORK" "testnet")
LNDHOST=$(set_default "$LNDHOST" "32f39c5ad7e7")
MACAROONPATH=$(set_default "$MACAROONPATH" "/root/.lnd/admin.macaroon")
TLSPATH=$(set_default "$TLSPATH" "/root/.lnd/tls.cert")
DEBUG=$(set_default "$TAPD_DEBUG" "debug")
HOSTNAME=$(hostname)

exec tapd \
  "--network=$NETWORK" \
  "--debuglevel=$DEBUG" \
  "--lnd.host=$LNDHOST:10009" \
  "--lnd.macaroonpath=$MACAROONPATH" \
  "--lnd.tlspath=$TLSPATH" \
  "--rpclisten=$HOSTNAME:10029" \
  "--rpclisten=127.0.0.1:10029" \
  "--restlisten=$HOSTNAME:8089"

