#!/bin/bash
#SBATCH --account=pawsey1193
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=100M
#SBATCH --time=01:00:00
#SBATCH --output=o_contig_locations.out

cd /scratch/pawsey1193/lleclerc/CUHK_new

#dos2unix /scratch/pawsey1193/lleclerc/CUHK_new/GHs/new_GH.txt

GENE_TABLE="/scratch/pawsey1193/lleclerc/CUHK_new/GHs/new_GH.txt"
GFF_DIR="/scratch/pawsey1193/lleclerc/CUHK_new/gff"
OUT="contig_locations.txt"

# Header
echo -e "Gene\tContig\tStart\tEnd\tStrand" > "$OUT"

tail -n +2 "$GENE_TABLE" | while read gene fasta gff rest; do
    GFF="$GFF_DIR/${gff}.gff3"

    # Find the gene/mRNA feature for this ID and pull contig (col1), start (col4), end (col5), strand (col7)
    RESULT=$(grep "$gene" "$GFF" | awk '$3 == "mRNA" || $3 == "gene"' | head -1 | awk '{print $1"\t"$4"\t"$5"\t"$7}')

    if [[ -z "$RESULT" ]]; then
        echo -e "$gene\tNOT FOUND\t-\t-\t-" >> "$OUT"
    else
        echo -e "$gene\t$RESULT" >> "$OUT"
    fi

done

echo "Done! Results in $OUT"
