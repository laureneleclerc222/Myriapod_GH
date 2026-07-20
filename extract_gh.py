import csv
import os
from Bio import SeqIO
from Bio.Seq import Seq

gff_dir = "/scratch/pawsey1193/lleclerc/CUHK_new/gff"
fasta_dir = "/scratch/pawsey1193/lleclerc/CUHK_new/genome"
output_dir = "/scratch/pawsey1193/lleclerc/CUHK_new/glycosyl_hydrolase_genes"
input_file = "/scratch/pawsey1193/lleclerc/CUHK_new/new_GH.txt"

# Ensure output directory exists
os.makedirs(output_dir, exist_ok=True)

# Read new_GH.txt and store gene details
gh_genes = []
with open(input_file, 'r', encoding='utf-8-sig') as file:
    reader = csv.DictReader(file, delimiter='\t')
    for row in reader:
        gh_genes.append(row)

def extract_gene_sequence(gff_file, fasta_file, accession):
    """Extracts nucleotide sequence of the gene from the genome using the GFF file."""
    sequences = SeqIO.to_dict(SeqIO.parse(fasta_file, "fasta"))
    gene_seq = None
    
    with open(gff_file, 'r') as gff:
        for line in gff:
            if line.startswith('#'):
                continue
            parts = line.strip().split('\t')
            if len(parts) < 9:
                continue
            
            feature_type, start, end, strand, attributes = (
                parts[2], int(parts[3]), int(parts[4]), parts[6], parts[8]
            )
            
            if feature_type == "gene" and f"ID={accession}" in attributes:
                contig = parts[0]
                if contig in sequences:
                    gene_seq = sequences[contig].seq[start-1:end]
                    if strand == "-":
                        gene_seq = gene_seq.reverse_complement()
                break  # Stop once gene is found
    return gene_seq

# Process each gene entry
for gene in gh_genes:
    accession = gene["Gene_accession"]
    genome_id = gene["Genome_gff"]
    
    gff_path = os.path.join(gff_dir, f"{genome_id}.gff3")
    fasta_path = os.path.join(fasta_dir, f"{genome_id}.fasta")
    
    if not os.path.exists(gff_path) or not os.path.exists(fasta_path):
        print(f"Missing files for {genome_id}: {gff_path} or {fasta_path}")
        continue
    
    gene_seq = extract_gene_sequence(gff_path, fasta_path, accession)
    if gene_seq:
        output_fasta = os.path.join(output_dir, f"{accession}.fasta")
        with open(output_fasta, 'w') as out_f:
            out_f.write(f">{accession}\n{gene_seq}\n")
        print(f"Saved {accession} sequence to {output_fasta}")
    else:
        print(f"Could not find sequence for {accession}")
