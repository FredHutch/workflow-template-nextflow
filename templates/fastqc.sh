#!/bin/bash

set -Eeuo pipefail

echo "Creating output folder"
mkdir fastqc

echo "Running FASTQC"
fastqc -o fastqc "$R1" "$R2"

echo "DONE"