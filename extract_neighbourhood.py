#!/usr/bin/env python3

import csv
import os
from Bio import SeqIO

# File paths
CONTIG_TABLE = "/scratch/pawsey1193/lleclerc/CUHK_new/contigs/contig_names.txt"
GFF_DIR      = "/scratch/pawsey1193/lleclerc/CUHK_new/gff"
GENOME_DIR   = "/scratch/pawsey1193/lleclerc/CUHK_new/genome"
OUTPUT_DIR   = "/scratch/pawsey1193/lleclerc/CUHK_new/contigs/neighbourhood"

#contig_names.txt looks like this 
#GH CDS  contig
#Ato_000013-T1   10x_75
#Ato_000266-T1   10x_125 etc...


WINDOW = 10000

os.makedirs(OUTPUT_DIR, exist_ok=True)

def get_genome_prefix(gene):
    """Extract genome prefix from gene name e.g. Ato_000013-T1 -> Ato"""
    return gene.split("_")[0]

def extract_cds_near_gene(gene, contig, gff_path, fasta_path, window=5000):
    contig_sequences = {}
    cds_list = []

    # Load genome sequences
    try:
        with open(fasta_path, 'r') as f:
            for record in SeqIO.parse(f, 'fasta'):
                contig_sequences[record.id] = record.seq
    except FileNotFoundError:
        print(f"  ERROR: FASTA not found: {fasta_path}")
        return []

    if contig not in contig_sequences:
        print(f"  ERROR: Contig {contig} not found in {fasta_path}")
        return []

    # Find the GH gene's start/end in the GFF3
    gene_start, gene_end = None, None
    try:
        with open(gff_path, 'r') as f:
            for line in f:
                if line.startswith('#'):
                    continue
                parts = line.strip().split('\t')
                if len(parts) < 9:
                    continue
                feature_type = parts[2]
                attributes   = parts[8]
                if feature_type in ["gene", "mRNA"] and (f"ID={gene}" in attributes or f"Parent={gene}" in attributes):
                    gene_start = int(parts[3])
                    gene_end   = int(parts[4])
                    break
    except FileNotFoundError:
        print(f"  ERROR: GFF not found: {gff_path}")
        return []

    if gene_start is None:
        print(f"  WARNING: {gene} not found in {gff_path}")
        return []

    # Define search window
    search_start = max(1, gene_start - window)
    search_end   = gene_end + window
    genome_seq   = contig_sequences[contig]

    print(f"  Found {gene} at {contig}:{gene_start}-{gene_end}, searching {search_start}-{search_end}")

    # Extract all CDS within the window
    try:
        with open(gff_path, 'r') as f:
            for line in f:
                if line.startswith('#'):
                    continue
                parts = line.strip().split('\t')
                if len(parts) < 9:
                    continue

                feature_type = parts[2]
                start        = int(parts[3])
                end          = int(parts[4])
                strand       = parts[6]
                attributes   = parts[8]

                if parts[0] == contig and feature_type == 'CDS' and start >= search_start and end <= search_end:
                    nuc_seq = genome_seq[start-1:end]

                    if strand == '-':
                        nuc_seq = nuc_seq.reverse_complement()

                    if len(nuc_seq) % 3 == 0:
                        prot_seq = str(nuc_seq.translate(to_stop=True))
                    else:
                        prot_seq = "ERROR: length not multiple of 3"

                    cds_list.append({
                        'GH_Gene':             gene,
                        'Contig':              contig,
                        'Feature':             feature_type,
                        'Start':               start,
                        'End':                 end,
                        'Strand':              strand,
                        'Attributes':          attributes,
                        'Nucleotide_Sequence': str(nuc_seq),
                        'Protein_Sequence':    prot_seq
                    })
    except Exception as e:
        print(f"  ERROR processing GFF: {e}")

    return cds_list


# Read contig_names.txt and process each gene
with open(CONTIG_TABLE, 'r') as f:
    reader = csv.DictReader(f, delimiter='\t')
    for row in reader:
        gene   = row['GH CDS'].strip()
        contig = row['contig'].strip()

        prefix  = get_genome_prefix(gene)
        gff     = os.path.join(GFF_DIR,    f"{prefix}.gff3")
        genome  = os.path.join(GENOME_DIR, f"{prefix}.fasta")

        print(f"Processing {gene} on {contig}...")

        cds_data = extract_cds_near_gene(gene, contig, gff, genome, window=WINDOW)

        if not cds_data:
            print(f"  No CDS found for {gene}")
            continue

        # Write CSV output
        out_file = os.path.join(OUTPUT_DIR, f"{gene}_cds_neighbourhood.csv")
        with open(out_file, 'w', newline='') as csvfile:
            fieldnames = ['GH_Gene', 'Contig', 'Feature', 'Start', 'End', 'Strand', 'Attributes', 'Nucleotide_Sequence', 'Protein_Sequence']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(cds_data)

        print(f"  Saved {len(cds_data)} CDS to {out_file}")

print("done")
