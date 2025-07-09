#!/usr/bin/env Rscript

library(viper)

# Inject variables
exp_mat_file <- "${expression_matrix}"
network_file <- "${network}"

# Load regulon and expression matrix
exp_mat <- read.table(exp_mat_file, header=TRUE)
exp_mat\$tmp <- exp_mat\$Unstranded

# Custom Regulon Loading
regul <- get(load(network_file))
regul <- pruneRegulon(regul, cutoff=100)

# Run VIPER
vpres <- viper(exp_mat, regul, verbose = TRUE)
colnames(vpres)[1] <- "${meta.id}"
vpres <- vpres[, "${meta.id}", drop=FALSE]

# Output result
output_file <- file.path("${meta.id}.${meta.reference}.${meta.network}.viper_matrix.tsv")
write.table(vpres, file = output_file, sep = "\t", quote = FALSE)

################################################
################################################
## VERSIONS FILE                              ##
################################################
################################################

viper_version <- as.character(packageVersion('viper'))

writeLines(
    c(
        '"${task.process}":',
        paste('    viper:', viper_version)
    ),
'versions.yml')

################################################
################################################
################################################
################################################