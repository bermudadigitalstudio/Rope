#!/usr/bin/env bash

# Auto generate the LinuxMain file using Sourcery
# Install sourcery with brew install sourcery

SOURCERY_VERSION="$(sourcery --version)"
if [ "$SOURCERY_VERSION" != "0.5.3" ]
then
  echo "You need sourcery 0.5.3 – please install via: brew install sourcery"
  exit 1
fi

#.build/debug/sourcery Tests/RopeTests Tests/LinuxMain.stencil Tests
sourcery Tests/RopeTests Tests/LinuxMain.stencil Tests
mv Tests/LinuxMain.generated.swift Tests/LinuxMain.swift
