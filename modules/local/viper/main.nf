process VIPER {
    tag "$meta.id|$meta.reference with $meta.network"
    label 'process_single'

    conda "${moduleDir}/environment.yml"

    input:
    tuple val(meta), path(expression_matrix), path(network)

    output:
    path "*.viper_matrix.tsv", emit: viper_matrix
    path "versions.yml",       emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    template 'viper.R'

    stub:
    prefix = task.ext.prefix ?: "${meta.id}.${meta.reference}.${meta.network}.viper_matrix.tsv"
    """
    touch ${prefix}.viper_matrix.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        viper: \$(Rscript -e "cat(as.character(packageVersion('viper')))"
    END_VERSIONS
    """
}
