#!/bin/bash

while true; do
  echo "150 requêtes envoyées d'un coup !"
  for i in {1..50}; do
    curl -s http://localhost:8000/api/fast > /dev/null &
    curl -s http://localhost:8000/api/slow > /dev/null &
    curl -s http://localhost:8000/api/error > /dev/null &
  done
  wait

  echo "Silence de 30s..."
  sleep 30
done
