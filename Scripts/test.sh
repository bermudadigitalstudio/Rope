#!/usr/bin/env bash
# DISCUSSION
# Two containers are created: one is based on the latest Postgres alpine image;
# the other contains the source code to Rope with libpq preinstalled. The two
# containers are linked with a bridge network and the Postgres container is
# accessible as the postgres host, exposing its DB on the default Postgres port.

# -e: exit when a command fails
# -x: print command as it executes
# -o pipefail: set exit status of shell script to last nonzero exit code, if any were nonzero.
set -exo pipefail

POSTGRES_CONTAINER_NAME=rope_tests_postgres
TEST_NETWORK_NAME=rope_tests

# Clean up everything we've made when shell exits
function finish {
  set +e # Do not exit when a command fails
  docker stop $POSTGRES_CONTAINER_NAME
  docker network rm $TEST_NETWORK_NAME
}
trap finish EXIT # Register finish function

# Create an isolated bridge network so that we can set a net alias (default bridge network doesn't allow this)
docker network create rope_tests

docker run -d `# Run it in background` \
  --rm `# Delete container when it stops` \
  --net $TEST_NETWORK_NAME `# Connect to test network` \
  --net-alias postgres `# Expose it on network behind hostname "postgres"` \
  --name $POSTGRES_CONTAINER_NAME `# Give it a specific name we can refer to later` \
  postgres:alpine # Specify the image – alpine is nice and tiny

docker build . -t rope # Build our image and name it 'rope'
sleep 5 # Wait for PG to come up
docker run --rm \
  --net $TEST_NETWORK_NAME \
  --env DATABASE_HOST=postgres \
  rope
