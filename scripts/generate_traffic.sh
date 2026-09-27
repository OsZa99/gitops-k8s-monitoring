#!/bin/bash

while true; do
  echo "150 requêtes envoyées d'un coup !"
  for i in {1..50}; do
    curl -s http:/chaos-api.local/api/fast > /dev/null &
    curl -s http://chaos-api.local/api/slow > /dev/null &
    curl -s http://chaos-api.local/api/error > /dev/null &
  done
  wait

  echo "Silence de 30s..."
  sleep 30
done
