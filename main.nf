#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

// Set default parameters
params.help = false
params.fastq_folder = false
params.output_folder = false

// Quality trimming
params.min_qvalue = 20
params.min_align_score = 40

// Set the containers to use for each component
params.container__cutadapt = "quay.io/biocontainers/cutadapt:3.5--py36hc5360cc_0"
params.container__fastqc = "quay.io/biocontainers/fastqc:0.11.9--hdfd78af_1"
params.container__multiqc = "quay.io/biocontainers/multiqc:1.11--pyhdfd78af_0"
params.container__bwa = "quay.io/hdc-workflows/bwa-samtools:latest"

// Import sub-workflows
include { quality_wf } from './modules/quality'
include { align_wf } from './modules/align'


// Function which prints help message text
def helpMessage() {
    log.info"""
Usage:

nextflow run FredHutch/workflow-template-nextflow <ARGUMENTS>

Required Arguments:
  --fastq_folder        Folder containing paired-end FASTQ files ending with .fastq.gz,
                        containing either "_R1" or "_R2" in the filename.
  --genome_fasta        Reference genome to use for alignment, in FASTA format
  --output_folder       Folder for output files

Optional Arguments:
  --min_qvalue          Minimum quality score used to trim data (default: ${params.min_qvalue})
  --min_align_score     Minimum alignment score (default: ${params.min_align_score})
    """.stripIndent()
}


// Main workflow
workflow {

    // Show help message if the user specifies the --help flag at runtime
    // or if any required params are not provided
    if ( params.help || params.fastq_folder == false || params.output_folder == false || params.genome_fasta == false ){
        // Invoke the function above which prints the help message
        helpMessage()
        // Exit out and do not run anything else
        exit 1
    }

    // Make a channel with the input FASTQ read pairs from the --fastq_folder
    // After calling `fromFilePairs`, the structure must be changed from
    // [specimen, [R1, R2]]
    // to
    // [specimen, R1, R2]
    // with the map{} expression
    fastq_ch = Channel
        .fromFilePairs("${params.fastq_folder}/*_R{1,2}*fastq.gz")
        .map{
            [it[0], it[1][0], it[1][1]]
        }

    // Tell the user if no data can be found
    fastq_ch.ifEmpty("No input data found in ${params.fastq_folder}")

    // Perform quality trimming on the input 
    quality_wf(
        fastq_ch
    )
    // output:
    //   reads:
    //     tuple val(specimen), path(read_1), path(read_2)

    // Align the quality-trimmed reads to the reference genome
    align_wf(
        quality_wf.out.reads,
        file(params.genome_fasta)
    )
    // output:
    //   bam:
    //     tuple val(specimen), path(bam)

}