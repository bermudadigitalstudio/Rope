#!/usr/bin/env bash
# DISCUSSION
# Two containers are created: one is based on the latest Postgres alpine image;
# the other contains the source code to Rope with libpq preinstalled. The two
# containers are linked with a bridge network and the Postgres container is
# accessible as the postgres host, exposing its DB on the default Postgres port.

# -e: exit when a command fails
# -o pipefail: set exit status of shell script to last nonzero exit code, if any were nonzero.
set -eo pipefail

# Clean up everything we've made when shell exits
function finish {
  set +e # Do not exit when a command fails
  docker stop rope_tests_postgres
}
trap finish EXIT # Register finish function

docker run  --name rope_tests_postgres --rm -d postgres:alpine

docker build -t rope . # Build our image and name it 'rope'
sleep 5 # Wait for PG to come up
docker run --rm --link rope_tests_postgres:localhost rope \
  || (set +x; echo -e "\033[0;31mTests exited with non-zero exit code\033[0m"; tput bel; exit 1)
