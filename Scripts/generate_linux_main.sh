#!/usr/bin/env bash

# Auto generate the LinuxMain file using Sourcery
SOURCERY_VERSION="$(.build/debug/sourcery --version)"
if [ "$SOURCERY_VERSION" != "0.5.3" ]
then
  echo "You need sourcery 0.5.3 – uncomment the line in Package.swift"
  exit 1
fi

.build/debug/sourcery Tests/RopeTests Tests/LinuxMain.stencil Tests
mv Tests/LinuxMain.generated.swift Tests/LinuxMain.swift
