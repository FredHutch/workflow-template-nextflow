#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

// Assess quality of input data
process fastqc_input {
    container "${params.container__fastqc}"
    
    input:
    tuple val(specimen), path(R1), path(R2)

    output:
    path "fastqc/*.zip", emit: zip
    path "fastqc/*.html", emit: html

    script:
    template 'fastqc.sh'

}

// Assess quality of trimmed data
process fastqc_trimmed {
    container "${params.container__fastqc}"
    
    input:
    tuple val(specimen), path(R1), path(R2)

    output:
    path "fastqc/*.zip", emit: zip
    path "fastqc/*.html", emit: html

    script:
    template 'fastqc.sh'

}

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

// Combine all FASTQC data into a single report
process multiqc_input {
    container "${params.container__multiqc}"
    publishDir "${params.output_folder}/input/", mode: 'copy', overwrite: true
    
    input:
    path "*"

    output:
    path "multiqc_report.html"

    script:
    template 'multiqc.sh'

}

// Combine all FASTQC data into a single report
process multiqc_trimmed {
    container "${params.container__multiqc}"
    publishDir "${params.output_folder}/quality_trimmed/", mode: 'copy', overwrite: true
    
    input:
    path "*"

    output:
    path "multiqc_report.html"

    script:
    template 'multiqc.sh'

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