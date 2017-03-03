#!/usr/bin/env bash

for file in "$@"; do
  zip -FS --junk-paths "${file%.*}.zip" $file
done