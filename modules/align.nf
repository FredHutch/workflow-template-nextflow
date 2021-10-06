#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

// Index a genome for alignment with BWA MEM
process bwa_index {
    container "${params.container__bwa}"
    
    input:
    path genome_fasta

    output:
    path "ref.tar.gz"

    script:
    template 'bwa_index.sh'

}

// Align reads with BWA MEM
process bwa {
    container "${params.container__bwa}"
    publishDir "${params.output_folder}/alignments/${specimen}/", mode: 'copy', overwrite: true
    
    input:
    tuple val(specimen), path(R1), path(R2)
    path ref

    output:
    tuple val(specimen), path("aligned.bam"), emit: bam

    script:
    template 'bwa.sh'

}

// Count up the number of aligned reads
process flagstats {
    container "${params.container__bwa}"
    
    input:
    tuple val(specimen), path(bam)

    output:
    file "${specimen}.flagstats"

    script:
    template 'flagstats.sh'

}

// Combine all flagstats data into a single report
process multiqc_flagstats {
    container "${params.container__multiqc}"
    publishDir "${params.output_folder}/alignments/", mode: 'copy', overwrite: true
    
    input:
    path "*"

    output:
    path "multiqc_report.html"

    script:
    template 'multiqc.sh'

}

workflow align_wf{

    take:
    reads_ch
    genome_fasta

    main:

    // Index the reference genome
    bwa_index(genome_fasta)

    // Align the reads
    bwa(reads_ch, bwa_index.out)

    // Count up the reads
    flagstats(bwa.out.bam)

    // Combine the flagstats reports
    multiqc_flagstats(flagstats.out.toSortedList())

    emit:
    bam = bwa.out.bam

}