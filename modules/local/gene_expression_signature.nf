process GENE_EXPRESSION_SIGNATURE {
    publishDir "${params.outdir}", mode: "copy"
    tag "${meta.id}|${meta.reference}"
    label 'process_medium'

    input:
    tuple val(meta), path(expression_counts), path(reference_counts)

    output:
    tuple val(meta), path("*.ges.tsv"), emit: ges

    script:
    def out_file = "${meta.id}.${meta.reference}.ges.tsv"
    """
    generate_gene_expression_signature.py \\
        --sample_expression ${expression_counts} \\
        --reference ${reference_counts} \\
        --output ${out_file}
    """
}