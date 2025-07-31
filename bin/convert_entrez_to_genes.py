#!/usr/bin/env python3

import random
import argparse
import pandas as pd
import mygene

def safe_querymany(mg, ids, retries=3, wait=None):
    if not wait:
        # gets a random wait time between 15 sec and 2 minutes
        wait = random.uniform(15, 120)
    for attempt in range(retries):
        try:
            return mg.querymany(ids, scopes='entrezgene', fields='symbol', species='human')
        except Exception as e:
            if attempt < retries - 1:
                time.sleep(wait)
            else:
                raise e

def convert_entrez_to_genes(entrez_file):
    """
    Convert Entrez IDs to gene symbols using MyGene.info.
    
    Parameters:
    entrez_file (str): Path to the input file containing Entrez IDs.
    
    Returns:
    pd.DataFrame: DataFrame with Entrez IDs and corresponding gene symbols.
    """
    # Load Entrez IDs
    df = pd.read_csv(entrez_file, sep="\t")
    df.index.name = "EntrezID"
    df.reset_index(inplace=True)
    
    # Query MyGene.info to map Entrez → Gene Symbols
    mg = mygene.MyGeneInfo()
    query_result = safe_querymany(
        mg,
        df["EntrezID"].tolist(),
    )
    
    # Build mapping dict
    mapping = {
        entry['query']: entry.get('symbol', None)
        for entry in query_result if 'symbol' in entry
    }
    
    # Map to Gene Symbols
    df["GeneSymbol"] = df["EntrezID"].astype(str).map(mapping)
    
    return df


def main():
    parser = argparse.ArgumentParser(description="Convert Entrez IDs to gene symbols.")
    parser.add_argument("--input_file", type=str, help="Path to the input file containing Entrez IDs.")
    parser.add_argument("--output_file", type=str, help="Path to save the output file with gene symbols.")

    args = parser.parse_args()
    # Convert Entrez IDs to gene symbols
    result_df = convert_entrez_to_genes(args.input_file)
    # Save the result to a file
    result_df.to_csv(args.output_file, sep="\t", index=False)
    print(f"Converted Entrez IDs saved to {args.output_file}")

if __name__ == "__main__":
    main()
