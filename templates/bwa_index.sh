#!/bin/bash

set -euo pipefail

echo "Input: $genome_fasta"

echo "Building index"
bwa \
    index \
    "${genome_fasta}"

ls -lahtr

echo "Combining into a tar"
tar -czvf ref.tar.gz ${genome_fasta}*

echo "DONE"