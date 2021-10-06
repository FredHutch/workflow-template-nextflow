#!/bin/bash

set -Eeuo pipefail

echo "Specimen: $specimen"
echo "R1: $R1"
echo "R2: $R2"

# Unpack the reference tarball
tar xzvf ${ref}

REF=\$(find -name "*.amb" | sed 's/.amb//')
echo "REF=\$REF"

echo "Running BWA MEM"
bwa \
    mem \
    -a \
    -t3 \
    \$REF \
    ${R1} \
    ${R2} \
| samtools \
    sort \
    -m3G \
    -@3 \
    -o aligned.bam -

echo "DONE"