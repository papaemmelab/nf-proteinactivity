/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { GENE_EXPRESSION_SIGNATURE } from '../../modules/local/gene_expression_signature.nf'
include { VIPER                     } from '../../modules/local/viper'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { samplesheetToList } from 'plugin/nf-schema'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


workflow PROTEINACTIVITY_SINGLE_SAMPLE {

    take:
    ch_samplesheet       // channel: path(sample_sheet.csv)
    ch_versions          // channel: [ path(versions.yml) ]

    main:

    //
    // Create channel from input file provided through params.input
    //
    Channel
        .fromList(samplesheetToList(params.input, "${projectDir}/assets/schema_input.json"))
        .map {
            meta, sample_path, reference_path, network_path ->
                return [ meta.id, meta ,[ sample_path, reference_path, network_path ] ]
        }
        .groupTuple()
        .set { ch_combinations }

    //
    // WORKFLOW: Run nf-proteinactivity workflow
    //

    ch_combinations
      .flatMap { sample_id, meta_list, files_list ->
        (0..<meta_list.size()).collect { i ->
          def meta = meta_list[i]
          def files = files_list[i]
          def expression_counts = files[0]
          def reference_counts = files[1]
          def regulon = files[2]

          // Use a join key that matches exactly what's in GES output
          def ges_id = [id: meta.id, reference: meta.reference]

          return tuple(ges_id, meta, regulon)
        }
      }
      .set { ch_viper_pairs }

    ch_combinations
        .flatMap { sample_id, meta_list, files_list ->
          (0..<meta_list.size()).collect { i ->
            def meta = meta_list[i]
            def files = files_list[i]
            def expression_counts = files[0]
            def reference_counts = files[1]
            def id = [id: meta.id, reference: meta.reference]
            return [id, expression_counts, reference_counts] // just enough to uniquely ID the GES job
          }
        }
        .distinct() // deduplicates by value
        .map { id, expr, ref -> tuple(id, expr, ref) }
        .set { ch_ges_inputs }

    // Now pass to GENE_EXPRESSION_SIGNATURE
    GENE_EXPRESSION_SIGNATURE(ch_ges_inputs)
    ch_ges_unique_outputs = GENE_EXPRESSION_SIGNATURE.out

    // ch_ges_unique_outputs.view { "GES OUT: $it" }
    // ch_viper_pairs.view { "VIPER PAIR: $it" }

    ch_ges_unique_outputs
      .combine(ch_viper_pairs)
      .filter { ges_key, ges_path, meta_key, meta, regulon ->
        ges_key == meta_key
      }
      .map { ges_key, ges_path, meta_key, meta, regulon ->
        tuple(meta, ges_path, regulon)
      }
      .set { ch_viper_inputs }

    VIPER(ch_viper_inputs)
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
