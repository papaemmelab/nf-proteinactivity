#!/usr/bin/env python3

import argparse
import numpy as np
import pandas as pd
import mygene

def convert_star_to_entrez(star_counts_file):
    # Load STAR output
    df = pd.read_csv(star_counts_file, sep="\t", header=None, comment="#")
    df.columns = ["GeneID", "Unstranded", "Strand1", "Strand2"]
    
    # Remove STAR-internal rows
    df = df[~df['GeneID'].str.startswith("N_")]
    
    # Keep only GeneID and unstranded count
    counts = df[["GeneID", "Unstranded"]].copy()
    
    # Strip version numbers from Ensembl IDs (e.g., ENSG000001234.5 -> ENSG000001234)
    counts["GeneID"] = counts["GeneID"].str.replace(r"\..*", "", regex=True)
    
    # Query MyGene.info to map Ensembl → Entrez
    mg = mygene.MyGeneInfo()
    query_result = mg.querymany(
        counts["GeneID"].tolist(),
        scopes='ensembl.gene',
        fields='entrezgene',
        species='human'
    )

    # Build mapping dict
    mapping = {
        entry['query']: str(entry.get('entrezgene'))
        for entry in query_result if 'entrezgene' in entry
    }

    # Map to Entrez
    counts["EntrezID"] = counts["GeneID"].map(mapping)
    counts = counts.dropna(subset=["EntrezID"])

    # Final formatting
    result_df = counts.set_index("EntrezID")[["Unstranded"]]
    
    return result_df


def CPM_normalization(dset):
    """
    Apply log2(CPM + 1) normalization to a count matrix.
    
    Parameters:
    dset (pd.DataFrame): Gene expression count matrix (genes x samples).
    
    Returns:
    pd.DataFrame: Normalized matrix.
    """
    # Calculate CPM
    cpm = dset.div(dset.sum(axis=0), axis=1) * 1e6
    # Add 1 and apply log2
    log2cpm = np.log2(cpm + 1)
    return log2cpm


def GES_scaled(dset, ref):
    """
    Compute Z score gene expression signature by scaling `dset` to the mean and SD of `ref`.
    
    Parameters:
    dset (pd.DataFrame): Expression matrix (genes x samples) to be scaled.
    ref (pd.DataFrame): Reference expression matrix (genes x samples) used for scaling.
    
    Returns:
    pd.DataFrame: Scaled expression matrix.
    """
    # Compute mean and std across columns (samples) for each gene
    ref_mean = ref.mean(axis=1)
    ref_sd = ref.std(axis=1)

    # Broadcast subtraction and division
    ges = dset.sub(ref_mean, axis=0).div(ref_sd, axis=0)

    # Drop rows with any non-finite values (NaN or Inf) across samples
    ges = ges[np.isfinite(ges.sum(axis=1))]

    return ges


def main():
    parser = argparse.ArgumentParser(
        description="Generate a gene expression signature for a single sample using a reference dataset."
    )
    parser.add_argument(
        "--sample_expression",
        required=True,
        type=str,
        help="Path to the input file containing gene expression counts for sample.",
    )
    parser.add_argument(
        "--reference",
        required=True,
        type=str,
        help="Path to TSV containing gene expression counts for reference samples.",
    )
    parser.add_argument(
        "--output",
        required=True,
        type=str,
        help="Path to the output file where the signature will be saved.",
    )
    
    args = parser.parse_args()

    sample_expression = args.sample_expression
    reference = args.reference
    output = args.output

    # Load the sample expression data
    sample_df = convert_star_to_entrez(sample_expression)
    # Sum counts for each gene if multiple entries exist
    sample_df = sample_df.groupby(sample_df.index).sum()

    # Load the reference data
    reference_df = pd.read_csv(reference, sep="\t", compression="infer", index_col=0)

    sample_df.index = sample_df.index.astype(str)
    reference_df.index = reference_df.index.astype(str)

    # Harmonize gene sets
    common_genes = sample_df.index.astype(str).intersection(reference_df.index.astype(str))
    sample_df = sample_df.loc[common_genes]
    reference_df = reference_df.loc[common_genes]
    
    # Normalize both datasets using CPM
    sample_df_cpm = CPM_normalization(sample_df)
    reference_df_cpm = CPM_normalization(reference_df)

    # Calculate the gene expression signature
    ges = GES_scaled(sample_df_cpm, reference_df_cpm)

    ges.to_csv(output, sep="\t")

if __name__ == "__main__":
    main()
