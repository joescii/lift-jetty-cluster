#!/usr/bin/env bash

sbt clean update stage

pushd ./target/universal/
jar -cvfM ./stage.jar ./stage
popd

docker build -f ./docker/Dockerfile -t lift-jetty-cluster .
