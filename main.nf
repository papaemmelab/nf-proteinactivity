#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-proteinactivity
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/papaemmelab/nf-proteinactivity
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { logSuccess
    logWarning
    logError
    logInfo
    mkdirs
    coloredTitle
    getAbsolute
} from './utils.nf'

include {
    PROTEINACTIVITY_SINGLE_SAMPLE
} from './workflows/proteinactivity'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow PROTEINACTIVITY{

    main:

    ch_versions = Channel.empty()

    //
    // WORKFLOW: Run nf-proteinactivty workflow
    //
    ch_samplesheet = Channel.value(file(params.input, checkIfExists: true))
    
    PROTEINACTIVITY_SINGLE_SAMPLE (
        ch_samplesheet,
        ch_versions
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    HELPERS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def showVersion() {
    version = "v0.0.1"
    
    log.info """\
        Repo: https://github.com/papaemmlab/nf-proteinactivity
        Version: ${version}
    """.stripIndent()
    exit 0
}

def showHelp() {
    logInfo """\
        Usage: nextflow run papaemmelab/nf-proteinactivity [options]

        Pipeline for inferring protein activity from gene expression data.
        
        For more info: https://github.com/papaemmlab/nf-proteinactivity
        
        Options:
            --input             Samplesheet [required].
            --outdir            Output location for results [required].
    """.stripIndent()
    exit 0
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    if (params.help) { showHelp() }
    if (params.version) { showVersion() }

    main:

    //
    // WORKFLOW: Run main workflow
    //
    PROTEINACTIVITY ()
}


workflow.onComplete {
    workflow.success
        ? logSuccess("\nDone! ${coloredTitle()}\u001B[32m ran successfully. See results: ${getAbsolute(params.outdir)}")
        : logError("\nOops .. something went wrong")
}