#!/bin/bash

NODE="$1"
IFS=$'\n'
for line in $(curl -s "$NODE/_cat/shards" | fgrep UNASSIGNED); do
  INDEX=$(echo $line | (awk '{print $1}'))
  SHARD=$(echo $line | (awk '{print $2}'))

  echo "curl -XPOST \"$NODE/_cluster/reroute\" -d '{ \"commands\": [ { \"allocate\": { \"index\": \"'$INDEX'\", \"shard\": '$SHARD',\"node\": \"'$NODE'\", \"allow_primary\": true } } ] }'"
done
