#!/bin/bash

protoc --elixir_out=plugins=grpc:apps/azra_server/lib/azra_server hooks.proto
protoc --elixir_out=plugins=grpc:apps/azra_client/lib/azra_client hooks.proto
