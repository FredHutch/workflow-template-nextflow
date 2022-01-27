#!/bin/bash

set -euo pipefail

echo "Creating output folder"
mkdir fastqc

echo "Running FASTQC"
fastqc -o fastqc "$R1" "$R2"

echo "DONE"