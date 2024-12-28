#!/bin/bash

cd "$1"

docker-compose pull
docker-compose restart || docker-compose up -d
