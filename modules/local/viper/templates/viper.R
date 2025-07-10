#!/usr/bin/env Rscript

library(viper)

# Inject variables
exp_mat_file <- "${expression_matrix}"
network_path <- "${network}"

# Load regulon and expression matrix
exp_mat <- read.table(exp_mat_file, header=TRUE)
exp_mat\$tmp <- exp_mat\$Unstranded

# Custom Regulon Loading
rda2list <- function(file) {
    e <- new.env()
    load(file, envir = e)
    pruneRegulon(e\$regul, cutoff = 100)
}

# Check if it exists
if (!file.exists(network_path)) {
  message("Network path does not exist.")
} else if (dir.exists(network_path)) {
    rda_files <- list.files(network_path, pattern = "\\\\.rda\$", full.names = TRUE)
    regul_obj <- Map(rda2list, rda_files)
} else {
    regul_obj <- get(load(network_path))
    regul_obj <- pruneRegulon(regul_obj, cutoff=100)
}

# Run VIPER
vpres <- viper(exp_mat, regul_obj, verbose = TRUE)
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