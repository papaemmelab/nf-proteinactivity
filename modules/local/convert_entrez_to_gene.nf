process CONVERT_ENTREZ_TO_GENE {
    publishDir "${params.outdir}", mode: "copy"
    tag "CONVERT GENES for $viper_matrix"
    label 'process_medium'

    input:
    path(viper_matrix)

    output:
    path("*.viper_matrix.genes.tsv"), emit: out

    script:
    def out_file = "${viper_matrix.baseName}.genes.tsv"
    """
    convert_entrez_to_genes.py \\
        --input_file ${viper_matrix} \\
        --output_file ${out_file}
    """
}