
// Combine all FASTQC data into a single report
process multiqc {
    container "${params.container__multiqc}"
    publishDir "${params.output_folder}/${params.output_subfolder}/", mode: 'copy', overwrite: true
    
    input:
    path "*"

    output:
    path "multiqc_report.html"

    script:
    template 'multiqc.sh'

}