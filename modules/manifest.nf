#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

process validate_manifest {
    // Run inside a container with Python/Pandas installed
    container "${params.container__pandas}"
  
    input:
        path manifest_csv

    output:
        file "manifest.csv"

    script:
    template 'validate_manifest.py'

}