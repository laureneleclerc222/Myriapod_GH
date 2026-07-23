#!/bin/bash
#SBATCH --job-name=blast_array_GH5_3
#SBATCH --account=pawsey1193
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --time=10:00:00
#SBATCH --array=1-5
#SBATCH --output=logs/blast_%A_%a.out
#SBATCH --error=logs/blast_%A_%a.err

cd /scratch/pawsey1193/lleclerc/CUHK_new/trees

GH=5
export PATH=/software/projects/pawsey1193/ncbi-blast-2.17.0+/bin:$PATH
export BLASTDB=/scratch/references/blastdb_update/blast-2026-06-01/db

mkdir -p /scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs/"$GH"

# get the file corresponding to this task
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" GH"${GH}"_samples.tsv)

INPUT="/scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/${GH}/${SAMPLE}.fasta"
OUTPUT="/scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs/${GH}/${SAMPLE}_vs_aa2_4751.blast.tsv"

blastp -db nr \
	-query "$INPUT" \
	-negative_taxids 2,4751 \
	-evalue 1e-5 \
	-max_target_seqs 50 \
	-out "$OUTPUT" \
	-num_threads $SLURM_CPUS_PER_TASK \
	-outfmt "6 qseqid sseqid sseq stitle pident length evalue bitscore staxids sscinames sacc sskingdoms ssphylum"


#replace spaces with underscores
awk '{gsub(/ /, "_"); print}' /scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs/"$GH"/"$SAMPLE"_vs_aa2_4751.blast.tsv > /scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs/"$GH"/"$SAMPLE"_vs_aa2_4751_.blast.tsv

#turn into fasta file
awk 'BEGIN { OFS = "\n" } { print ">"$11"_"$4"_"$12, $3 }' /scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs/"$GH"/"$SAMPLE"_vs_aa2_4751_.blast.tsv > /scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs/"$GH"/"$SAMPLE"_vs_aa2_4751.fasta

