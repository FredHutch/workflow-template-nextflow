#!/bin/bash

# Run the workflow on the test data, and write the output to output/
nextflow \
    run \
    -profile docker \
    ../main.nf \
    --fastq_folder fastq \
    --genome_fasta genome_fasta/NC_001422.1.fasta \
    --output_folder output \
    -with-report \
    -resume
