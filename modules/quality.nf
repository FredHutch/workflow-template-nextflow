#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

// Import the fastqc and multiqc processes so that they can 
// each be used in two places independently
include { fastqc as fastqc_input } from './fastqc'
include { fastqc as fastqc_trimmed } from './fastqc'
// Using the output_subfolder parameter, we can publish the output from
// each invocation of multiqc to a different location
include { multiqc as multiqc_input } from './multiqc' addParams(output_subfolder: 'input')
include { multiqc as multiqc_trimmed } from './multiqc' addParams(output_subfolder: 'quality_trimmed')

// Perform quality trimming on the input FASTQ data
process quality_trim {
    container "${params.container__cutadapt}"
    
    input:
    tuple val(specimen), path(R1), path(R2)

    output:
    tuple val(specimen), path("${R1.name.replaceAll(/.fastq.gz/, '')}.trimmed.fastq.gz"), path("${R2.name.replaceAll(/.fastq.gz/, '')}.trimmed.fastq.gz"), emit: reads
    tuple val(specimen), path("${specimen}.cutadapt.json"), emit: log

    script:
    template 'quality_trim.sh'

}

workflow quality_wf{

    take:
    reads_ch
    // tuple val(specimen), path(read_1), path(read_2)

    main:

    // Generate quality metrics for the input data
    fastqc_input(reads_ch)

    // Combine all of the FASTQC data for the input data
    multiqc_input(fastqc_input.out.zip.flatten().toSortedList())

    // Run quality trimming
    quality_trim(reads_ch)

    // Generate quality metrics for the trimmed data
    fastqc_trimmed(quality_trim.out.reads)

    // Combine all of the FASTQC data for the trimmed data
    multiqc_trimmed(fastqc_trimmed.out.zip.flatten().toSortedList())

    emit:
    reads = quality_trim.out.reads

}